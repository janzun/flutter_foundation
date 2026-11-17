-- ============================================================================
-- 统一中台 RPC 函数定义模板 ({{SCHEMA}} -> common / common_test)
--
-- 统一返回规范 (JSONB):
-- {
--   "code":    0 | <错误码>,     -- 0 代表成功；非 0 代表业务/鉴权错误
--   "message": "string",        -- 人类可读的状态描述或错误原因
--   "data":    { ... } | null   -- 业务载荷数据，失败时为 null
-- }
--
-- 统一错误码字典:
--   0     : 成功 (Success)
--   20001 : 未授权或会话已过期 (Unauthorized / Session Expired)
--   20002 : 账号状态异常/已被封禁 (User Banned)
--   20003 : 应用未注册或已停用 (App Not Found)
--   20004 : 用户档案未同步或不存在 (User Not Found)
--   30001 : 请求参数不合法 (Invalid Parameter)
--   30002 : 商品不存在或已下架 (Product Not Found / Inactive)
--   30003 : 原订单未找到 (Original Order Not Found)
--   30004 : 资产/积分余额不足 (Insufficient Balance)
-- ============================================================================

-- 1. sync_user_profile: 同步登录用户档案并返回最小化前端必要字段
CREATE OR REPLACE FUNCTION {{SCHEMA}}.sync_user_profile(p_app_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'auth', '{{SCHEMA}}'
AS $function$
DECLARE
    v_supabase_uid UUID := auth.uid();
    v_user_row RECORD;
    v_auth_user RECORD;
    v_is_new_user BOOLEAN := FALSE;
    v_entitlements JSONB;
    v_data JSONB;
BEGIN
    IF v_supabase_uid IS NULL THEN
        RETURN jsonb_build_object('code', 20001, 'message', '未授权或会话已过期，请重新登录', 'data', NULL);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM {{SCHEMA}}.apps WHERE id = p_app_id) THEN
        RETURN jsonb_build_object('code', 20003, 'message', '应用未注册或已停用', 'data', NULL);
    END IF;

    SELECT * INTO v_auth_user FROM auth.users WHERE id = v_supabase_uid;

    INSERT INTO {{SCHEMA}}.users (
        app_id, supabase_uid, email, phone, display_name, auth_provider, last_login_at
    ) VALUES (
        p_app_id,
        v_supabase_uid,
        v_auth_user.email,
        v_auth_user.phone,
        CASE
            WHEN v_auth_user.is_anonymous IS TRUE THEN '访客'
            ELSE COALESCE(v_auth_user.raw_user_meta_data->>'full_name', split_part(v_auth_user.email, '@', 1), '用户')
        END,
        COALESCE(v_auth_user.raw_app_meta_data->>'provider', CASE WHEN v_auth_user.is_anonymous IS TRUE THEN 'anonymous' ELSE 'email' END),
        NOW()
    )
    ON CONFLICT (app_id, supabase_uid)
    DO UPDATE SET
        last_login_at = NOW(),
        email = COALESCE(EXCLUDED.email, {{SCHEMA}}.users.email),
        phone = COALESCE(EXCLUDED.phone, {{SCHEMA}}.users.phone),
        auth_provider = EXCLUDED.auth_provider,
        updated_at = NOW()
    RETURNING *, (xmax = 0) AS is_inserted
    INTO v_user_row;

    IF v_user_row.risk_level = 'banned' THEN
        RETURN jsonb_build_object('code', 20002, 'message', '账号状态异常，暂无法登录', 'data', NULL);
    END IF;

    v_is_new_user := v_user_row.is_inserted;

    -- 查询用户在当前应用下的所有有效/在存资产（若无则聚合为空数组 []）
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'type', type,
                'code', code,
                'status', status,
                'tier', tier,
                'billing_cycle', billing_cycle,
                'balance', balance,
                'expire_at', expire_at
            )
        ), '[]'::jsonb
    ) INTO v_entitlements
    FROM {{SCHEMA}}.user_entitlements
    WHERE user_id = v_user_row.id AND app_id = p_app_id::text;

    v_data := jsonb_build_object(
        'id', v_user_row.id,
        'is_anonymous', (v_user_row.auth_provider = 'anonymous'),
        'is_new_user', v_is_new_user,
        'email', v_user_row.email,
        'display_name', v_user_row.display_name,
        'avatar_url', v_user_row.avatar_url,
        'entitlements', v_entitlements
    );

    RETURN jsonb_build_object('code', 0, 'message', 'success', 'data', v_data);
END;
$function$;

-- 2. provision_entitlements: 支付/续费发权（幂等）
CREATE OR REPLACE FUNCTION {{SCHEMA}}.provision_entitlements(
    p_app_id text,
    p_user_id uuid,
    p_product_code text,
    p_store text,
    p_channel_transaction_id text,
    p_original_transaction_id text DEFAULT NULL::text,
    p_total_amount numeric DEFAULT 0.00,
    p_currency text DEFAULT 'USD'::text,
    p_platform text DEFAULT 'unknown'::text,
    p_metadata jsonb DEFAULT '{}'::jsonb,
    p_order_no text DEFAULT NULL::text,
    p_expire_at timestamp with time zone DEFAULT NULL::timestamp with time zone
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'auth', '{{SCHEMA}}'
AS $function$
DECLARE
  v_resolved_user_id UUID;
  v_product RECORD;
  v_has_product BOOLEAN := FALSE;
  v_order_id UUID;
  v_order_no TEXT;
  v_order_type TEXT;
  v_billing_cycle TEXT;
  v_existing_order RECORD;
  v_current_ent RECORD;
  v_new_expire_at TIMESTAMPTZ;
  v_new_balance NUMERIC;
  v_perk_key TEXT;
  v_perk_val JSONB;
  v_perk_amount NUMERIC;
BEGIN
  SELECT id INTO v_resolved_user_id
  FROM {{SCHEMA}}.users
  WHERE id = p_user_id
     OR (app_id::text = p_app_id AND supabase_uid = p_user_id)
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'code', 20004,
      'message', 'User not found in users for id/uid: ' || p_user_id::text,
      'data', NULL
    );
  END IF;

  SELECT * INTO v_existing_order
  FROM {{SCHEMA}}.orders
  WHERE store = p_store AND channel_transaction_id = p_channel_transaction_id;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'code', 0,
      'message', 'Transaction already processed',
      'data', jsonb_build_object(
        'is_duplicate', true,
        'order_id', v_existing_order.id,
        'order_no', v_existing_order.order_no
      )
    );
  END IF;

  SELECT * INTO v_product
  FROM {{SCHEMA}}.products
  WHERE app_id = p_app_id
    AND (code = p_product_code OR store_product_id = p_product_code)
  LIMIT 1;

  v_has_product := FOUND;
  IF v_has_product THEN
    v_order_type := v_product.type;
    v_billing_cycle := COALESCE(v_product.billing_cycle, 'one_off');
  ELSE
    v_order_type := 'consumable';
    v_billing_cycle := 'one_off';
  END IF;

  IF p_order_no IS NOT NULL THEN
    UPDATE {{SCHEMA}}.orders SET
      channel_transaction_id = p_channel_transaction_id,
      original_transaction_id = COALESCE(p_original_transaction_id, original_transaction_id),
      total_amount = CASE WHEN p_total_amount > 0 THEN p_total_amount ELSE total_amount END,
      currency = COALESCE(NULLIF(p_currency, ''), currency),
      status = 'paid',
      paid_at = now(),
      metadata = {{SCHEMA}}.orders.metadata || p_metadata,
      updated_at = now()
    WHERE order_no = p_order_no
      AND app_id = p_app_id
      AND user_id = v_resolved_user_id
      AND status = 'pending'
    RETURNING id, order_no INTO v_order_id, v_order_no;
  END IF;

  IF v_order_id IS NULL THEN
    v_order_no := COALESCE(
      p_order_no,
      'ORD_' || to_char(now(), 'YYYYMMDDHH24MISS') || '_' || substr(md5(random()::text), 1, 6)
    );

    INSERT INTO {{SCHEMA}}.orders (
      app_id, user_id, order_no, product_code, type, billing_cycle,
      total_amount, currency, platform, store, channel_transaction_id,
      original_transaction_id, status, paid_at, metadata
    ) VALUES (
      p_app_id, v_resolved_user_id, v_order_no,
      CASE WHEN v_has_product THEN v_product.code ELSE p_product_code END,
      v_order_type, v_billing_cycle, p_total_amount, p_currency,
      p_platform, p_store, p_channel_transaction_id,
      p_original_transaction_id, 'paid', now(), p_metadata
    ) RETURNING id INTO v_order_id;
  END IF;

  IF NOT v_has_product THEN
    RETURN jsonb_build_object(
      'code', 0,
      'message', 'Order recorded (no product entitlement rule matched)',
      'data', jsonb_build_object(
        'is_duplicate', false,
        'order_id', v_order_id,
        'order_no', v_order_no
      )
    );
  END IF;

  IF v_product.reward_tier IS NOT NULL
     AND (v_billing_cycle = 'lifetime' OR p_expire_at IS NOT NULL OR COALESCE(v_product.reward_duration_days, 0) > 0) THEN

    IF v_billing_cycle = 'lifetime' THEN
      v_new_expire_at := NULL;
    ELSIF p_expire_at IS NOT NULL THEN
      v_new_expire_at := p_expire_at;
    ELSE
      SELECT * INTO v_current_ent
      FROM {{SCHEMA}}.user_entitlements
      WHERE user_id = v_resolved_user_id
        AND app_id = p_app_id
        AND type = 'membership'
        AND code = v_product.reward_tier;

      IF FOUND AND v_current_ent.expire_at IS NOT NULL AND v_current_ent.expire_at > now() THEN
        v_new_expire_at := v_current_ent.expire_at + (v_product.reward_duration_days || ' days')::INTERVAL;
      ELSE
        v_new_expire_at := now() + (v_product.reward_duration_days || ' days')::INTERVAL;
      END IF;
    END IF;

    INSERT INTO {{SCHEMA}}.user_entitlements (
      app_id, user_id, type, code, status, tier, billing_cycle,
      is_auto_renewable, expire_at, external_subscription_id, updated_at
    ) VALUES (
      p_app_id, v_resolved_user_id, 'membership', v_product.reward_tier, 'active',
      v_product.reward_tier, v_billing_cycle, (v_order_type = 'subscription'),
      v_new_expire_at, p_original_transaction_id, now()
    )
    ON CONFLICT (user_id, app_id, type, code) DO UPDATE SET
      status = 'active',
      tier = EXCLUDED.tier,
      billing_cycle = EXCLUDED.billing_cycle,
      is_auto_renewable = EXCLUDED.is_auto_renewable,
      expire_at = CASE
        WHEN EXCLUDED.billing_cycle = 'lifetime' THEN NULL
        ELSE EXCLUDED.expire_at
      END,
      external_subscription_id = COALESCE(EXCLUDED.external_subscription_id, {{SCHEMA}}.user_entitlements.external_subscription_id),
      updated_at = now();

    INSERT INTO {{SCHEMA}}.entitlement_transactions (
      app_id, user_id, order_id, type, code, tx_type, delta, expire_after, description
    ) VALUES (
      p_app_id, v_resolved_user_id, v_order_id, 'membership', v_product.reward_tier,
      'purchase', 0, v_new_expire_at,
      'Membership granted: ' || v_product.reward_tier || ' (' || v_billing_cycle || ')'
    );
  END IF;

  IF COALESCE(v_product.reward_points, 0) > 0 THEN
    INSERT INTO {{SCHEMA}}.user_entitlements (
      app_id, user_id, type, code, status, balance, total_earned, updated_at
    ) VALUES (
      p_app_id, v_resolved_user_id, 'points', 'standard_point', 'active',
      v_product.reward_points, v_product.reward_points, now()
    )
    ON CONFLICT (user_id, app_id, type, code) DO UPDATE SET
      status = 'active',
      balance = {{SCHEMA}}.user_entitlements.balance + EXCLUDED.balance,
      total_earned = {{SCHEMA}}.user_entitlements.total_earned + EXCLUDED.total_earned,
      updated_at = now()
    RETURNING balance INTO v_new_balance;

    INSERT INTO {{SCHEMA}}.entitlement_transactions (
      app_id, user_id, order_id, type, code, tx_type, delta, balance_after, description
    ) VALUES (
      p_app_id, v_resolved_user_id, v_order_id, 'points', 'standard_point',
      'purchase', v_product.reward_points, v_new_balance,
      'Points purchased via ' || v_product.code
    );
  END IF;

  IF v_product.reward_perks IS NOT NULL AND v_product.reward_perks <> '{}'::jsonb THEN
    FOR v_perk_key, v_perk_val IN SELECT * FROM jsonb_each(v_product.reward_perks)
    LOOP
      v_perk_amount := (v_perk_val#>>'{}')::NUMERIC;
      IF v_perk_amount > 0 THEN
        INSERT INTO {{SCHEMA}}.user_entitlements (
          app_id, user_id, type, code, status, balance, total_earned, updated_at
        ) VALUES (
          p_app_id, v_resolved_user_id, 'quota', v_perk_key, 'active',
          v_perk_amount, v_perk_amount, now()
        )
        ON CONFLICT (user_id, app_id, type, code) DO UPDATE SET
          status = 'active',
          balance = {{SCHEMA}}.user_entitlements.balance + EXCLUDED.balance,
          total_earned = {{SCHEMA}}.user_entitlements.total_earned + EXCLUDED.total_earned,
          updated_at = now()
        RETURNING balance INTO v_new_balance;

        INSERT INTO {{SCHEMA}}.entitlement_transactions (
          app_id, user_id, order_id, type, code, tx_type, delta, balance_after, description
        ) VALUES (
          p_app_id, v_resolved_user_id, v_order_id, 'quota', v_perk_key,
          'purchase', v_perk_amount, v_new_balance,
          'Quota perk granted: ' || v_perk_key
        );
      END IF;
    END LOOP;
  END IF;

  RETURN jsonb_build_object(
    'code', 0,
    'message', 'Entitlements provisioned successfully',
    'data', jsonb_build_object(
      'is_duplicate', false,
      'order_id', v_order_id,
      'order_no', v_order_no
    )
  );
END;
$function$;

-- 3. revoke_entitlements: 退款撤销权益与扣减资产（幂等）
CREATE OR REPLACE FUNCTION {{SCHEMA}}.revoke_entitlements(
    p_app_id text,
    p_channel_transaction_id text,
    p_refund_amount numeric DEFAULT NULL::numeric,
    p_refund_reason text DEFAULT 'Customer refund request'::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'auth', '{{SCHEMA}}'
AS $function$
DECLARE
  v_order RECORD;
  v_product RECORD;
  v_new_balance NUMERIC;
  v_perk_key TEXT;
  v_perk_val JSONB;
  v_perk_amount NUMERIC;
BEGIN
  SELECT * INTO v_order
  FROM {{SCHEMA}}.orders
  WHERE app_id = p_app_id AND channel_transaction_id = p_channel_transaction_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF NOT FOUND THEN
    SELECT * INTO v_order
    FROM {{SCHEMA}}.orders
    WHERE app_id = p_app_id AND original_transaction_id = p_channel_transaction_id
    ORDER BY created_at DESC
    LIMIT 1;
  END IF;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'code', 30003,
      'message', 'Original order not found for transaction: ' || p_channel_transaction_id,
      'data', NULL
    );
  END IF;

  IF v_order.status = 'refunded' THEN
    RETURN jsonb_build_object(
      'code', 0,
      'message', 'Order already refunded',
      'data', jsonb_build_object('is_duplicate', true, 'order_id', v_order.id)
    );
  END IF;

  UPDATE {{SCHEMA}}.orders SET
    status = 'refunded',
    refunded_at = now(),
    refund_amount = COALESCE(p_refund_amount, v_order.total_amount),
    refund_reason = p_refund_reason,
    updated_at = now()
  WHERE id = v_order.id;

  SELECT * INTO v_product
  FROM {{SCHEMA}}.products
  WHERE app_id = v_order.app_id AND code = v_order.product_code
  LIMIT 1;

  IF FOUND THEN
    IF v_product.reward_tier IS NOT NULL THEN
      UPDATE {{SCHEMA}}.user_entitlements SET
        status = 'expired',
        is_auto_renewable = false,
        expire_at = now(),
        updated_at = now()
      WHERE user_id = v_order.user_id
        AND app_id = v_order.app_id
        AND type = 'membership'
        AND code = v_product.reward_tier;

      INSERT INTO {{SCHEMA}}.entitlement_transactions (
        app_id, user_id, order_id, type, code, tx_type, delta, expire_after, description
      ) VALUES (
        v_order.app_id, v_order.user_id, v_order.id, 'membership', v_product.reward_tier,
        'refund', 0, now(), 'Membership revoked due to refund'
      );
    END IF;

    IF COALESCE(v_product.reward_points, 0) > 0 THEN
      UPDATE {{SCHEMA}}.user_entitlements SET
        balance = GREATEST(balance - v_product.reward_points, 0),
        total_spent = total_spent + LEAST(balance, v_product.reward_points),
        updated_at = now()
      WHERE user_id = v_order.user_id AND app_id = v_order.app_id
        AND type = 'points' AND code = 'standard_point'
      RETURNING balance INTO v_new_balance;

      INSERT INTO {{SCHEMA}}.entitlement_transactions (
        app_id, user_id, order_id, type, code, tx_type, delta, balance_after, description
      ) VALUES (
        v_order.app_id, v_order.user_id, v_order.id, 'points', 'standard_point',
        'refund', -v_product.reward_points, COALESCE(v_new_balance, 0), 'Points revoked due to refund'
      );
    END IF;

    IF v_product.reward_perks IS NOT NULL AND v_product.reward_perks <> '{}'::jsonb THEN
      FOR v_perk_key, v_perk_val IN SELECT * FROM jsonb_each(v_product.reward_perks)
      LOOP
        v_perk_amount := (v_perk_val#>>'{}')::NUMERIC;
        IF v_perk_amount > 0 THEN
          UPDATE {{SCHEMA}}.user_entitlements SET
            balance = GREATEST(balance - v_perk_amount, 0),
            total_spent = total_spent + LEAST(balance, v_perk_amount),
            updated_at = now()
          WHERE user_id = v_order.user_id AND app_id = v_order.app_id
            AND type = 'quota' AND code = v_perk_key
          RETURNING balance INTO v_new_balance;

          INSERT INTO {{SCHEMA}}.entitlement_transactions (
            app_id, user_id, order_id, type, code, tx_type, delta, balance_after, description
          ) VALUES (
            v_order.app_id, v_order.user_id, v_order.id, 'quota', v_perk_key,
            'refund', -v_perk_amount, COALESCE(v_new_balance, 0), 'Quota revoked due to refund'
          );
        END IF;
      END LOOP;
    END IF;
  END IF;

  IF v_order.total_amount > 50 THEN
    UPDATE {{SCHEMA}}.users SET risk_level = 'high', updated_at = now() WHERE id = v_order.user_id;
  END IF;

  RETURN jsonb_build_object(
    'code', 0,
    'message', 'Entitlements revoked successfully',
    'data', jsonb_build_object('is_duplicate', false, 'order_id', v_order.id)
  );
END;
$function$;

-- 4. transfer_entitlements: 恢复购买跨账号迁移会员权益
CREATE OR REPLACE FUNCTION {{SCHEMA}}.transfer_entitlements(
    p_app_id text,
    p_from_uid uuid,
    p_to_uid uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'auth', '{{SCHEMA}}'
AS $function$
DECLARE
  v_from_user_id UUID;
  v_to_user_id UUID;
  v_ent RECORD;
  v_count INTEGER := 0;
BEGIN
  SELECT id INTO v_from_user_id FROM {{SCHEMA}}.users
  WHERE id = p_from_uid OR (app_id::text = p_app_id AND supabase_uid = p_from_uid) LIMIT 1;

  SELECT id INTO v_to_user_id FROM {{SCHEMA}}.users
  WHERE id = p_to_uid OR (app_id::text = p_app_id AND supabase_uid = p_to_uid) LIMIT 1;

  IF v_from_user_id IS NULL OR v_to_user_id IS NULL OR v_from_user_id = v_to_user_id THEN
    RETURN jsonb_build_object(
      'code', 0,
      'message', 'Transfer skipped (source or target user invalid or identical)',
      'data', jsonb_build_object('skipped', true, 'transferred_count', 0)
    );
  END IF;

  FOR v_ent IN
    SELECT * FROM {{SCHEMA}}.user_entitlements
    WHERE user_id = v_from_user_id AND app_id = p_app_id
      AND type = 'membership' AND status = 'active' AND tier <> 'free'
  LOOP
    INSERT INTO {{SCHEMA}}.user_entitlements (
      app_id, user_id, type, code, status, tier, billing_cycle,
      is_auto_renewable, expire_at, external_subscription_id, updated_at
    ) VALUES (
      p_app_id, v_to_user_id, v_ent.type, v_ent.code, 'active', v_ent.tier,
      v_ent.billing_cycle, v_ent.is_auto_renewable, v_ent.expire_at,
      v_ent.external_subscription_id, now()
    )
    ON CONFLICT (user_id, app_id, type, code) DO UPDATE SET
      status = 'active',
      tier = EXCLUDED.tier,
      billing_cycle = EXCLUDED.billing_cycle,
      is_auto_renewable = EXCLUDED.is_auto_renewable,
      expire_at = EXCLUDED.expire_at,
      external_subscription_id = COALESCE(EXCLUDED.external_subscription_id, {{SCHEMA}}.user_entitlements.external_subscription_id),
      updated_at = now();

    UPDATE {{SCHEMA}}.user_entitlements
    SET status = 'expired', is_auto_renewable = false, updated_at = now()
    WHERE id = v_ent.id;

    INSERT INTO {{SCHEMA}}.entitlement_transactions (app_id, user_id, type, code, tx_type, delta, expire_after, description)
    VALUES
      (p_app_id, v_from_user_id, v_ent.type, v_ent.code, 'transfer_out', 0, now(), 'Transferred out via restore'),
      (p_app_id, v_to_user_id, v_ent.type, v_ent.code, 'transfer_in', 0, v_ent.expire_at, 'Transferred in via restore');

    v_count := v_count + 1;
  END LOOP;

  RETURN jsonb_build_object(
    'code', 0,
    'message', 'Transferred successfully',
    'data', jsonb_build_object('skipped', false, 'transferred_count', v_count)
  );
END;
$function$;

-- 5. create_pending_order: 国内/Stripe 预下单
CREATE OR REPLACE FUNCTION {{SCHEMA}}.create_pending_order(
    p_app_id text,
    p_product_code text,
    p_store text,
    p_platform text DEFAULT 'unknown'::text,
    p_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'auth', '{{SCHEMA}}'
AS $function$
DECLARE
  v_auth_uid UUID := auth.uid();
  v_user_id UUID;
  v_product RECORD;
  v_order_id UUID;
  v_order_no TEXT;
BEGIN
  IF v_auth_uid IS NULL THEN
    RETURN jsonb_build_object('code', 20001, 'message', '未授权或会话已过期，请重新登录', 'data', NULL);
  END IF;

  SELECT id INTO v_user_id
  FROM {{SCHEMA}}.users
  WHERE app_id::text = p_app_id AND supabase_uid = v_auth_uid
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('code', 20004, 'message', '用户档案尚未同步', 'data', NULL);
  END IF;

  SELECT * INTO v_product
  FROM {{SCHEMA}}.products
  WHERE app_id = p_app_id
    AND is_active = true
    AND (code = p_product_code OR store_product_id = p_product_code)
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('code', 30002, 'message', '商品不存在或已下架: ' || p_product_code, 'data', NULL);
  END IF;

  v_order_no := 'ORD_' || to_char(now(), 'YYYYMMDDHH24MISS') || '_' || substr(md5(random()::text), 1, 6);

  INSERT INTO {{SCHEMA}}.orders (
    app_id, user_id, order_no, product_code, type, billing_cycle,
    total_amount, currency, platform, store, status, metadata
  ) VALUES (
    p_app_id, v_user_id, v_order_no, v_product.code, v_product.type,
    COALESCE(v_product.billing_cycle, 'one_off'),
    v_product.price, v_product.currency, p_platform, p_store, 'pending', p_metadata
  ) RETURNING id INTO v_order_id;

  RETURN jsonb_build_object(
    'code', 0,
    'message', 'Pending order created',
    'data', jsonb_build_object(
      'order_id', v_order_id,
      'order_no', v_order_no,
      'amount', v_product.price,
      'currency', v_product.currency
    )
  );
END;
$function$;

-- 6. consume_entitlement: 原子扣减积分/额度
CREATE OR REPLACE FUNCTION {{SCHEMA}}.consume_entitlement(
    p_app_id uuid,
    p_type text,
    p_code text,
    p_amount numeric DEFAULT 1.0,
    p_description text DEFAULT 'Consume entitlement'::text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'auth', '{{SCHEMA}}'
AS $function$
DECLARE
  v_auth_uid UUID := auth.uid();
  v_user_id UUID;
  v_new_balance NUMERIC;
BEGIN
  IF v_auth_uid IS NULL THEN
    RETURN jsonb_build_object('code', 20001, 'message', '未授权或会话已过期，请重新登录', 'data', NULL);
  END IF;

  IF p_amount <= 0 THEN
    RETURN jsonb_build_object('code', 30001, 'message', '扣减数量必须大于 0', 'data', NULL);
  END IF;

  SELECT id INTO v_user_id
  FROM {{SCHEMA}}.users
  WHERE app_id = p_app_id AND supabase_uid = v_auth_uid
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('code', 20004, 'message', '用户档案不存在', 'data', NULL);
  END IF;

  UPDATE {{SCHEMA}}.user_entitlements SET
    balance = balance - p_amount,
    total_spent = total_spent + p_amount,
    updated_at = now()
  WHERE user_id = v_user_id
    AND app_id = p_app_id::text
    AND type = p_type
    AND code = p_code
    AND status = 'active'
    AND balance >= p_amount
  RETURNING balance INTO v_new_balance;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('code', 30004, 'message', '可用余额不足', 'data', NULL);
  END IF;

  INSERT INTO {{SCHEMA}}.entitlement_transactions (
    app_id, user_id, type, code, tx_type, delta, balance_after, description
  ) VALUES (
    p_app_id::text, v_user_id, p_type, p_code, 'consume', -p_amount, v_new_balance, p_description
  );

  RETURN jsonb_build_object(
    'code', 0,
    'message', 'Entitlement consumed',
    'data', jsonb_build_object('balance_after', v_new_balance)
  );
END;
$function$;

-- 权限最小化授予
REVOKE ALL ON FUNCTION {{SCHEMA}}.provision_entitlements(text, uuid, text, text, text, text, numeric, text, text, jsonb, text, timestamptz) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION {{SCHEMA}}.provision_entitlements(text, uuid, text, text, text, text, numeric, text, text, jsonb, text, timestamptz) TO service_role;

REVOKE ALL ON FUNCTION {{SCHEMA}}.revoke_entitlements(text, text, numeric, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION {{SCHEMA}}.revoke_entitlements(text, text, numeric, text) TO service_role;

REVOKE ALL ON FUNCTION {{SCHEMA}}.transfer_entitlements(text, uuid, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION {{SCHEMA}}.transfer_entitlements(text, uuid, uuid) TO service_role;

REVOKE ALL ON FUNCTION {{SCHEMA}}.create_pending_order(text, text, text, text, jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION {{SCHEMA}}.create_pending_order(text, text, text, text, jsonb) TO authenticated, service_role;

REVOKE ALL ON FUNCTION {{SCHEMA}}.consume_entitlement(uuid, text, text, numeric, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION {{SCHEMA}}.consume_entitlement(uuid, text, text, numeric, text) TO authenticated, service_role;

REVOKE ALL ON FUNCTION {{SCHEMA}}.sync_user_profile(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION {{SCHEMA}}.sync_user_profile(uuid) TO authenticated, service_role;
