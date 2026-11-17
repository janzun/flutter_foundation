import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { handleProdEvent, type RevenueCatEvent } from "./revenuecat_prod.ts";
import { handleTestEvent } from "./revenuecat_test.ts";

interface RevenueCatWebhookPayload {
  api_version: string;
  event: RevenueCatEvent;
}

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
function isUuid(val?: string | null): val is string {
  return Boolean(val && UUID_REGEX.test(val));
}

/**
 * 路由判定：决定当前 Webhook 事件应交由测试服处理器还是正式服处理器处理
 *
 * 1. 直接读取客户端通过 Purchases.setAttributes 注入的 `$debug` 布尔标记（"true" -> 测试服，"false" -> 正式服），
 *    无需在客户端或 Webhook 路由层暴露或硬编码数据库 Schema 名称；
 * 2. 若事件本身不携带 subscriber_attributes（如部分 TRANSFER 迁移事件），则通过用户 UUID 反查其归属环境兜底。
 */
async function isTestRoute(supabase: SupabaseClient, event: RevenueCatEvent): Promise<boolean> {
  const debugAttr = (
    event.subscriber_attributes?.["$debug"]?.value ??
    event.subscriber_attributes?.["debug"]?.value
  )?.toLowerCase();

  if (debugAttr === "true") return true;
  if (debugAttr === "false") return false;

  const candidateIds = [
    event.app_user_id,
    ...(event.aliases || []),
    ...(event.transferred_to || []),
    ...(event.transferred_from || []),
  ].filter(isUuid);

  for (const uid of candidateIds) {
    const { data: testUser } = await supabase
      .schema("common_test")
      .from("users")
      .select("id")
      .or(`supabase_uid.eq."${uid}",id.eq."${uid}"`)
      .limit(1)
      .maybeSingle();
    if (testUser) return true;
  }

  return false;
}

/**
 * RevenueCat Webhook 统一入口（仅负责验签与环境路由分发，业务处理分别隔离在 prod / test 模块）
 */
Deno.serve(async (req: Request) => {
  // 1. 仅接受 POST 请求
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  // 2. 鉴权校验：支持 Authorization Bearer Token 或自定义 X-RevenueCat-Webhook-Secret 头
  const webhookSecret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET");
  if (webhookSecret) {
    const authHeader = req.headers.get("Authorization") || "";
    const customHeader = req.headers.get("X-RevenueCat-Webhook-Secret") || "";
    const bearerToken = authHeader.startsWith("Bearer ") ? authHeader.slice(7).trim() : authHeader.trim();

    if (bearerToken !== webhookSecret && customHeader !== webhookSecret) {
      console.warn("[Webhook] Unauthorized request rejected");
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }
  }

  // 3. 解析 JSON 请求体
  let payload: RevenueCatWebhookPayload;
  try {
    payload = await req.json();
  } catch (err) {
    console.error("[Webhook] Invalid JSON:", err);
    return new Response(JSON.stringify({ error: "Invalid JSON" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const event = payload?.event;
  if (!event || !event.type) {
    return new Response(JSON.stringify({ message: "Ignored: missing event" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // 4. RevenueCat 控制台 "Send Test Event" 连通性测试直接放行
  if (event.type === "TEST") {
    return new Response(JSON.stringify({ success: true, message: "Webhook test verified" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  // 使用 Service Role 客户端以绕过 RLS，安全调用底层发权 RPC
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // 5. 按环境隔离分发至正式处理器或测试处理器
  try {
    const useTest = await isTestRoute(supabase, event);
    console.info(`[Webhook] Routing ${event.type} (id: ${event.id}) -> ${useTest ? "common_test" : "common"}`);

    if (useTest) {
      return await handleTestEvent(supabase, event);
    }
    return await handleProdEvent(supabase, event);
  } catch (error: unknown) {
    const errMsg = error instanceof Error ? error.message : String(error);
    console.error(`[Webhook] Error for event ${event.id}:`, errMsg);
    // 返回 500 触发 RevenueCat 指数退避重试，避免偶发网络/数据库抖动丢单
    return new Response(JSON.stringify({ success: false, error: errMsg }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
