import { SupabaseClient } from "jsr:@supabase/supabase-js@2";

/**
 * RevenueCat Webhook 事件核心字段定义
 * 参考文档: https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields
 */
export interface RevenueCatEvent {
  id: string;
  type:
    | "INITIAL_PURCHASE"
    | "RENEWAL"
    | "NON_RENEWING_PURCHASE"
    | "CANCELLATION"
    | "UNCANCELLATION"
    | "EXPIRATION"
    | "BILLING_ISSUE"
    | "PRODUCT_CHANGE"
    | "TRANSFER"
    | "SUBSCRIPTION_PAUSED"
    | "SUBSCRIPTION_EXTENDED"
    | "EXPIRATION_EXTENDED"
    | "TEMPORARY_ENTITLEMENT_GRANT"
    | "TEST";
  app_id?: string;
  app_user_id?: string;
  aliases?: string[];
  original_app_user_id?: string;
  product_id?: string;
  new_product_id?: string;
  entitlement_id?: string;
  entitlement_ids?: string[];
  period_type?: string;
  purchased_at_ms?: number;
  grace_period_expires_date_ms?: number | null;
  expiration_at_ms?: number | null;
  auto_resume_at_ms?: number | null;
  store?: string;
  environment?: "SANDBOX" | "PRODUCTION";
  is_trial_conversion?: boolean;
  cancel_reason?:
    | "UNSUBSCRIBE"
    | "BILLING_ERROR"
    | "DEVELOPER_INITIATED"
    | "PRICE_INCREASE"
    | "CUSTOMER_SUPPORT"
    | "SUBSCRIPTION_PAUSED"
    | "UNKNOWN"
    | string;
  expiration_reason?: string;
  price?: number;
  price_in_purchased_currency?: number;
  currency?: string;
  transaction_id?: string;
  original_transaction_id?: string;
  transferred_from?: string[];
  transferred_to?: string[];
  country_code?: string;
  subscriber_attributes?: Record<string, { value: string; updated_at_ms?: number }>;
}

/** 正式服锁定操作的数据库 Schema */
const SCHEMA = "common";

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
function isUuid(val?: string | null): val is string {
  return Boolean(val && UUID_REGEX.test(val));
}

/** 规范化 RevenueCat 的商店与运行平台标识 */
function normalizeStore(storeRaw?: string): { store: string; platform: string } {
  const s = (storeRaw || "").toUpperCase();
  switch (s) {
    case "APP_STORE":
      return { store: "app_store", platform: "ios" };
    case "MAC_APP_STORE":
      return { store: "app_store", platform: "macos" };
    case "PLAY_STORE":
      return { store: "play_store", platform: "android" };
    case "STRIPE":
      return { store: "stripe", platform: "web" };
    case "AMAZON":
      return { store: "amazon", platform: "android" };
    case "PROMOTIONAL":
      return { store: "promotional", platform: "all" };
    default:
      return { store: s.toLowerCase() || "unknown", platform: "unknown" };
  }
}

/**
 * 将客户端传入的 supabase_uid 解析为业务表的主键 common.users.id
 * （entitlement_transactions.user_id 外键指向 users.id，直接插 supabase_uid 会报错）
 */
async function resolveCommonUserId(
  supabase: SupabaseClient,
  appId: string,
  candidateUids: (string | undefined | null)[]
): Promise<string | null> {
  const validUuids = candidateUids.filter(isUuid);
  for (const uid of validUuids) {
    const { data } = await supabase
      .schema(SCHEMA)
      .from("users")
      .select("id")
      .eq("app_id", appId)
      .or(`id.eq."${uid}",supabase_uid.eq."${uid}"`)
      .limit(1)
      .maybeSingle();
    if (data?.id) return data.id;
  }
  return null;
}

/**
 * 正式服事件处理器（锁定操作 common Schema，日常迭代测试请勿修改此文件）
 */
export async function handleProdEvent(supabase: SupabaseClient, event: RevenueCatEvent): Promise<Response> {
  // 1. 事件级幂等性去重：RevenueCat 为 at-least-once 投递，防止重试时重复写入流水和埋点
  if (event.id) {
    const { data: existingEvt } = await supabase
      .schema(SCHEMA)
      .from("events")
      .select("id")
      .eq("event_type", "payment")
      .eq("properties->>revenuecat_event_id", event.id)
      .limit(1)
      .maybeSingle();

    if (existingEvt) {
      return new Response(JSON.stringify({ success: true, schema: SCHEMA, duplicate: true, event_id: event.id }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }
  }

  // 2. 三级智能推导定位目标 app_id (UUID)
  //    途径 A：客户端注入的 subscriber_attributes.$app_id
  //    途径 B：通过商品标识从 products 表反查
  //    途径 C：通过用户 UID（含 TRANSFER 迁移数组）从 users 表反查
  let appId: string | null = null;
  const attrAppId = event.subscriber_attributes?.["$app_id"]?.value || event.subscriber_attributes?.["app_id"]?.value;
  if (isUuid(attrAppId)) appId = attrAppId;

  if (!appId && event.product_id) {
    const pid = event.product_id;
    const { data: prod } = await supabase
      .schema(SCHEMA)
      .from("products")
      .select("app_id")
      .or(`store_product_id.eq."${pid}",code.eq."${pid}"`)
      .limit(1)
      .maybeSingle();
    if (prod?.app_id && isUuid(prod.app_id)) appId = prod.app_id;
  }

  if (!appId) {
    const candidateIds = [
      event.app_user_id,
      ...(event.aliases || []),
      ...(event.transferred_to || []),
      ...(event.transferred_from || []),
    ].filter(isUuid);

    for (const uid of candidateIds) {
      const { data: u } = await supabase
        .schema(SCHEMA)
        .from("users")
        .select("app_id")
        .or(`supabase_uid.eq."${uid}",id.eq."${uid}"`)
        .limit(1)
        .maybeSingle();
      if (u?.app_id && isUuid(u.app_id)) {
        appId = u.app_id;
        break;
      }
    }
  }

  if (!appId) {
    console.error(`[Webhook:${SCHEMA}] Unable to resolve app_id for event ${event.id}`);
    // 无法定位应用的孤立事件返回 200 避免无限重试
    return new Response(JSON.stringify({ success: false, schema: SCHEMA, message: "Unable to resolve app_id" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // 3. 解析用户标识与商品对应的会员等级编码 (reward_tier)
  const candidateUids = [event.app_user_id, ...(event.aliases || [])];
  const targetSupabaseUid = candidateUids.find(isUuid) || null;
  const commonUserId = await resolveCommonUserId(supabase, appId, candidateUids);

  let productRewardTier: string | null = null;
  if (event.product_id) {
    const pid = event.product_id;
    const { data: prodInfo } = await supabase
      .schema(SCHEMA)
      .from("products")
      .select("reward_tier")
      .eq("app_id", appId)
      .or(`store_product_id.eq."${pid}",code.eq."${pid}"`)
      .limit(1)
      .maybeSingle();
    productRewardTier = prodInfo?.reward_tier || null;
  }

  const { store, platform } = normalizeStore(event.store);
  const expireAt = event.expiration_at_ms ? new Date(event.expiration_at_ms).toISOString() : null;
  const originalTxId = event.original_transaction_id || event.transaction_id || "";
  const currentTxId = event.transaction_id || originalTxId;

  // 4. 核心支付生命周期事件处理
  switch (event.type) {
    // --------------------------------------------------------
    // A. 首购 / 自动续费 / 消耗品买断 / 套餐升降级 -> 原子发权
    // --------------------------------------------------------
    case "INITIAL_PURCHASE":
    case "RENEWAL":
    case "NON_RENEWING_PURCHASE":
    case "PRODUCT_CHANGE": {
      const userIdForRpc = commonUserId || targetSupabaseUid;
      if (!userIdForRpc) {
        return new Response(JSON.stringify({ success: false, message: "User UUID missing" }), {
          status: 500,
          headers: { "Content-Type": "application/json" },
        });
      }

      const productCode = event.new_product_id || event.product_id || "";
      const { data: provResult, error: provErr } = await supabase.schema(SCHEMA).rpc("provision_entitlements", {
        p_app_id: appId,
        p_user_id: userIdForRpc,
        p_product_code: productCode,
        p_store: store,
        p_channel_transaction_id: currentTxId,
        p_original_transaction_id: originalTxId,
        p_total_amount: event.price_in_purchased_currency ?? event.price ?? 0,
        p_currency: event.currency || "USD",
        p_platform: platform,
        p_metadata: {
          revenuecat_event_id: event.id,
          revenuecat_event_type: event.type,
          environment: event.environment,
          period_type: event.period_type,
          country_code: event.country_code,
          is_trial_conversion: event.is_trial_conversion ?? false,
        },
        p_order_no: null,
        p_expire_at: expireAt,
      });

      if (provErr) throw provErr;
      // 若 RPC 返回业务失败（例如并发竞态导致 sync_user_profile 尚未落库），返回 500 触发重试
      if (provResult && provResult.code !== 0) {
        console.warn(`[Webhook:${SCHEMA}] provision_entitlements code=${provResult.code}:`, provResult.message);
        return new Response(JSON.stringify(provResult), {
          status: 500,
          headers: { "Content-Type": "application/json" },
        });
      }
      break;
    }

    // --------------------------------------------------------
    // B. 取消或退款（RevenueCat 通过 cancel_reason 区分真实含义）
    // --------------------------------------------------------
    case "CANCELLATION": {
      // B1. 商店客服退款 (CUSTOMER_SUPPORT)：立即作废订单并撤销全部对应权益
      if (event.cancel_reason === "CUSTOMER_SUPPORT") {
        const { error: revokeErr } = await supabase.schema(SCHEMA).rpc("revoke_entitlements", {
          p_app_id: appId,
          p_channel_transaction_id: currentTxId || originalTxId,
          p_refund_amount: event.price_in_purchased_currency ?? event.price ?? null,
          p_refund_reason: "Store customer support refund (RevenueCat)",
        });
        if (revokeErr) throw revokeErr;
        break;
      }

      // B2. 普通取消自动续费 (UNSUBSCRIBE 等)：合规铁律，本周期已付费不得立即剥夺 VIP，仅关闭自动续期标志
      let updateQuery = supabase
        .schema(SCHEMA)
        .from("user_entitlements")
        .update({ is_auto_renewable: false, updated_at: new Date().toISOString() })
        .eq("app_id", appId);

      if (originalTxId) {
        updateQuery = updateQuery.eq("external_subscription_id", originalTxId);
      } else if (commonUserId && productRewardTier) {
        updateQuery = updateQuery.eq("user_id", commonUserId).eq("type", "membership").eq("code", productRewardTier);
      }
      await updateQuery;

      if (commonUserId) {
        await supabase.schema(SCHEMA).from("entitlement_transactions").insert({
          app_id: appId,
          user_id: commonUserId,
          type: "membership",
          code: productRewardTier || event.entitlement_ids?.[0] || event.entitlement_id || "vip",
          tx_type: "cancel_auto_renew",
          delta: 0,
          description: `Auto-renewal cancelled (${event.cancel_reason || "user_request"})`,
        });
      }
      break;
    }

    // --------------------------------------------------------
    // C. 重新开启自动续订（用户在到期前恢复续费）
    // --------------------------------------------------------
    case "UNCANCELLATION": {
      let query = supabase
        .schema(SCHEMA)
        .from("user_entitlements")
        .update({ is_auto_renewable: true, status: "active", updated_at: new Date().toISOString() })
        .eq("app_id", appId);

      if (originalTxId) {
        query = query.eq("external_subscription_id", originalTxId);
      } else if (commonUserId && productRewardTier) {
        query = query.eq("user_id", commonUserId).eq("type", "membership").eq("code", productRewardTier);
      }
      await query;
      break;
    }

    // --------------------------------------------------------
    // D. 订阅周期彻底结束且未续费 -> 置为过期
    // --------------------------------------------------------
    case "EXPIRATION": {
      let query = supabase
        .schema(SCHEMA)
        .from("user_entitlements")
        .update({ status: "expired", is_auto_renewable: false, updated_at: new Date().toISOString() })
        .eq("app_id", appId);

      if (originalTxId) {
        query = query.eq("external_subscription_id", originalTxId);
      } else if (commonUserId && productRewardTier) {
        query = query.eq("user_id", commonUserId).eq("type", "membership").eq("code", productRewardTier);
      }
      await query;

      if (commonUserId) {
        await supabase.schema(SCHEMA).from("entitlement_transactions").insert({
          app_id: appId,
          user_id: commonUserId,
          type: "membership",
          code: productRewardTier || event.entitlement_ids?.[0] || event.entitlement_id || "vip",
          tx_type: "expire",
          delta: 0,
          expire_after: new Date().toISOString(),
          description: `Subscription expired (${event.expiration_reason || "period_ended"})`,
        });
      }
      break;
    }

    // --------------------------------------------------------
    // E. 恢复购买 / 跨账号权益迁移（旧匿名号自动失效）
    // --------------------------------------------------------
    case "TRANSFER": {
      const fromUid = (event.transferred_from || []).find(isUuid);
      const toUid = (event.transferred_to || []).find(isUuid);
      if (fromUid && toUid && fromUid !== toUid) {
        const { error: xferErr } = await supabase.schema(SCHEMA).rpc("transfer_entitlements", {
          p_app_id: appId,
          p_from_uid: fromUid,
          p_to_uid: toUid,
        });
        if (xferErr) throw xferErr;
      }
      break;
    }

    // --------------------------------------------------------
    // F. 扣款失败进入宽限期（合并写入 metadata，保留原有扩展字段）
    // --------------------------------------------------------
    case "BILLING_ISSUE": {
      const { data: existingEnt } = await supabase
        .schema(SCHEMA)
        .from("user_entitlements")
        .select("id, metadata")
        .eq("app_id", appId)
        .eq("external_subscription_id", originalTxId)
        .limit(1)
        .maybeSingle();

      if (existingEnt) {
        const mergedMetadata = {
          ...(typeof existingEnt.metadata === "object" && existingEnt.metadata !== null ? existingEnt.metadata : {}),
          billing_issue: true,
          grace_period_expires_at: event.grace_period_expires_date_ms
            ? new Date(event.grace_period_expires_date_ms).toISOString()
            : null,
          billing_issue_reported_at: new Date().toISOString(),
        };
        await supabase
          .schema(SCHEMA)
          .from("user_entitlements")
          .update({ metadata: mergedMetadata, updated_at: new Date().toISOString() })
          .eq("id", existingEnt.id);
      }
      break;
    }

    // --------------------------------------------------------
    // G. 订阅有效期延长（商店赠送 / Google Play 暂停恢复）
    // --------------------------------------------------------
    case "EXPIRATION_EXTENDED":
    case "SUBSCRIPTION_EXTENDED": {
      if (expireAt) {
        await supabase
          .schema(SCHEMA)
          .from("user_entitlements")
          .update({ expire_at: expireAt, status: "active", updated_at: new Date().toISOString() })
          .eq("app_id", appId)
          .eq("external_subscription_id", originalTxId);
      }
      break;
    }

    // --------------------------------------------------------
    // H. Google Play 订阅暂停
    // --------------------------------------------------------
    case "SUBSCRIPTION_PAUSED": {
      await supabase
        .schema(SCHEMA)
        .from("user_entitlements")
        .update({ status: "paused", is_auto_renewable: false, updated_at: new Date().toISOString() })
        .eq("app_id", appId)
        .eq("external_subscription_id", originalTxId);
      break;
    }
  }

  // 5. 记录支付审计埋点（同时作为 event.id 幂等去重凭证）
  await supabase.schema(SCHEMA).from("events").insert({
    app_id: appId,
    user_id: commonUserId || targetSupabaseUid,
    event_name: `revenuecat_${event.type.toLowerCase()}`,
    event_type: "payment",
    platform: platform,
    properties: {
      revenuecat_event_id: event.id,
      store: store,
      product_id: event.product_id,
      cancel_reason: event.cancel_reason,
      transaction_id: currentTxId,
      original_transaction_id: originalTxId,
      price: event.price_in_purchased_currency ?? event.price,
      currency: event.currency,
      environment: event.environment,
    },
    occurred_time: event.purchased_at_ms ? new Date(event.purchased_at_ms).toISOString() : new Date().toISOString(),
  });

  return new Response(JSON.stringify({ success: true, schema: SCHEMA, event_id: event.id }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}
