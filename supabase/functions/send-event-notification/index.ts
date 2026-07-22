// Sends the Expo push for an already-created in-app notification. The
// notifications + notification_recipients rows are inserted directly by
// public.notify_user() in SQL (guaranteed, no network dependency) -- this
// function's only job is the best-effort push send, fired via pg_net from
// that same SQL function.
//
// Deploy via Supabase Dashboard -> Edge Functions -> New Function -> paste
// this file. Turn OFF "Verify JWT" -- pg_net calls it directly with no user
// session, and it authenticates via the X-Cron-Secret header, same as
// scheduled-push-sender (reuses that same CRON_SECRET function secret, no
// new secret needed).
//
// Call with: { "notification_id": "...", "user_id": "..." }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "Content-Type": "application/json" };
const EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send";

Deno.serve(async (req: Request) => {
  try {
    const cronSecret = Deno.env.get("CRON_SECRET");
    if (!cronSecret || req.headers.get("X-Cron-Secret") !== cronSecret) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: jsonHeaders });
    }

    const payload = await req.json().catch(() => null);
    const notificationId = payload?.notification_id;
    const userId = payload?.user_id;
    if (!notificationId || !userId) {
      return new Response(JSON.stringify({ error: "notification_id and user_id are required" }), {
        status: 400,
        headers: jsonHeaders,
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) {
      return new Response(JSON.stringify({ error: "Server misconfigured" }), { status: 500, headers: jsonHeaders });
    }
    const admin = createClient(supabaseUrl, serviceRoleKey);

    const [{ data: notification }, { data: profile }] = await Promise.all([
      admin.from("notifications").select("title, body").eq("id", notificationId).maybeSingle(),
      admin.from("profiles").select("push_token").eq("id", userId).maybeSingle(),
    ]);

    if (!notification || !profile?.push_token || !profile.push_token.startsWith("ExponentPushToken")) {
      return new Response(JSON.stringify({ success: true, pushed: false }), { status: 200, headers: jsonHeaders });
    }

    const res = await fetch(EXPO_PUSH_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify([
        {
          to: profile.push_token,
          title: notification.title,
          body: notification.body,
          data: { notificationId },
        },
      ]),
    });
    const resBody = await res.json().catch(() => null);
    const ticket = Array.isArray(resBody?.data) ? resBody.data[0] : null;

    return new Response(
      JSON.stringify({ success: true, pushed: ticket?.status === "ok", ticket: ticket ?? undefined }),
      { status: 200, headers: jsonHeaders }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: jsonHeaders });
  }
});
