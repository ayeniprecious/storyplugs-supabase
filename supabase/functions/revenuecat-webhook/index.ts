// Receives RevenueCat webhook events and updates profiles.is_premium
// server-side -- this is the only place is_premium actually changes for a
// real purchase (the client SDK's own CustomerInfo is used for instant UI
// feedback right after a purchase, but the database is only ever updated
// here, using the service_role key, matching protect_is_premium()'s
// service_role bypass).
//
// Deploy via Supabase Dashboard -> Edge Functions -> New Function -> paste
// this file -> Deploy. Turn OFF "Verify JWT" for this function in the
// dashboard -- RevenueCat calls this server-to-server with its own
// Authorization header (checked below against REVENUECAT_WEBHOOK_SECRET),
// not a Supabase user session, so Supabase's own JWT check would reject it.
//
// Required Edge Function secrets (Dashboard -> Edge Functions -> Secrets):
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY -- auto-provided by the platform
//   REVENUECAT_WEBHOOK_SECRET -- any string you choose; set the same value
//     as the "Authorization header" when you create this webhook in the
//     RevenueCat dashboard (Project Settings -> Integrations -> Webhooks)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "Content-Type": "application/json" };

const PREMIUM_ENTITLEMENT_ID = "premium";

// Events that mean the user now has (or still has) the premium entitlement.
// TRANSFER covers a purchase being transferred onto this app_user_id.
const GRANT_EVENT_TYPES = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
  "TRANSFER",
  "NON_RENEWING_PURCHASE",
  "SUBSCRIPTION_EXTENDED",
  "TEMPORARY_ENTITLEMENT_GRANT",
]);

// Only EXPIRATION means access has actually ended. CANCELLATION just means
// auto-renew was turned off -- the entitlement stays active until the
// current period's expiration, which RevenueCat reports as a later,
// separate EXPIRATION event. BILLING_ISSUE similarly doesn't revoke access
// immediately (RevenueCat's own grace period applies); it either resolves
// (RENEWAL) or eventually expires (EXPIRATION).
const REVOKE_EVENT_TYPES = new Set(["EXPIRATION"]);

Deno.serve(async (req: Request) => {
  try {
    const webhookSecret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!webhookSecret || !supabaseUrl || !serviceRoleKey) {
      return new Response(
        JSON.stringify({
          error: "Server misconfigured: missing REVENUECAT_WEBHOOK_SECRET/SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY",
        }),
        { status: 500, headers: jsonHeaders }
      );
    }

    const authHeader = req.headers.get("Authorization");
    if (authHeader !== `Bearer ${webhookSecret}` && authHeader !== webhookSecret) {
      return new Response(JSON.stringify({ error: "Invalid webhook secret" }), {
        status: 401,
        headers: jsonHeaders,
      });
    }

    const payload = await req.json().catch(() => null);
    const event = payload?.event;
    if (!event?.app_user_id || !event?.type) {
      return new Response(JSON.stringify({ error: "Malformed webhook payload" }), {
        status: 400,
        headers: jsonHeaders,
      });
    }

    // Ignore events for entitlements/products this app doesn't grant premium
    // for, and events this integration deliberately treats as no-ops
    // (CANCELLATION, BILLING_ISSUE, etc. -- see REVOKE_EVENT_TYPES comment).
    const entitlementIds: string[] = event.entitlement_ids ?? (event.entitlement_id ? [event.entitlement_id] : []);
    const touchesPremiumEntitlement = entitlementIds.length === 0 || entitlementIds.includes(PREMIUM_ENTITLEMENT_ID);

    let nextIsPremium: boolean | null = null;
    if (touchesPremiumEntitlement && GRANT_EVENT_TYPES.has(event.type)) nextIsPremium = true;
    else if (touchesPremiumEntitlement && REVOKE_EVENT_TYPES.has(event.type)) nextIsPremium = false;

    if (nextIsPremium === null) {
      return new Response(JSON.stringify({ success: true, ignored: event.type }), {
        status: 200,
        headers: jsonHeaders,
      });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { error: updateError } = await adminClient
      .from("profiles")
      .update({ is_premium: nextIsPremium })
      .eq("id", event.app_user_id);

    if (updateError) {
      return new Response(JSON.stringify({ error: updateError.message }), {
        status: 500,
        headers: jsonHeaders,
      });
    }

    return new Response(JSON.stringify({ success: true, is_premium: nextIsPremium }), {
      status: 200,
      headers: jsonHeaders,
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: jsonHeaders });
  }
});
