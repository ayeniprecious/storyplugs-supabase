// Admin-only: creates a notification, fans it out to recipient rows (all users, one user, or a
// selected list of users), and sends a real Expo push to each recipient's stored push_token.
// Deploy via Supabase Dashboard -> Edge Functions -> New Function -> paste this file -> Deploy.
//
// Call with:
//   Authorization: Bearer <admin's access token>
//   { "title": "...", "body": "...", "target": "all" }
//   { "title": "...", "body": "...", "target": "user", "targetUserId": "<uuid>" }
//   { "title": "...", "body": "...", "target": "selected", "targetUserIds": ["<uuid>", ...] }
// Optional: "storyId": "<uuid>" to deep-link the notification to a single story.
// Optional: "storyIds": ["<uuid>", ...] to attach an ordered list of stories instead
// (rendered as a ranked poster row in the app) -- the two are independent, a
// notification can carry either, both, or neither.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "Content-Type": "application/json" };
const EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send";

Deno.serve(async (req: Request) => {
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
        status: 401,
        headers: jsonHeaders,
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !anonKey || !serviceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Server misconfigured: missing Supabase env vars" }),
        { status: 500, headers: jsonHeaders }
      );
    }

    const callerClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await callerClient.auth.getUser();
    if (userError || !userData?.user) {
      return new Response(JSON.stringify({ error: "Invalid session" }), {
        status: 401,
        headers: jsonHeaders,
      });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const { data: adminRow } = await adminClient
      .from("admins")
      .select("id")
      .eq("user_id", userData.user.id)
      .maybeSingle();
    if (!adminRow) {
      return new Response(JSON.stringify({ error: "Not an admin" }), {
        status: 403,
        headers: jsonHeaders,
      });
    }

    const payload = await req.json().catch(() => null);
    const { title, body, target, targetUserId, targetUserIds, storyId, storyIds } = payload ?? {};
    if (!title || !body || (target !== "all" && target !== "user" && target !== "selected")) {
      return new Response(
        JSON.stringify({ error: "Required: title, body, target ('all', 'user', or 'selected')" }),
        { status: 400, headers: jsonHeaders }
      );
    }
    if (target === "user" && !targetUserId) {
      return new Response(JSON.stringify({ error: "targetUserId is required when target is 'user'" }), {
        status: 400,
        headers: jsonHeaders,
      });
    }
    if (target === "selected" && (!Array.isArray(targetUserIds) || targetUserIds.length === 0)) {
      return new Response(
        JSON.stringify({ error: "targetUserIds (non-empty array) is required when target is 'selected'" }),
        { status: 400, headers: jsonHeaders }
      );
    }

    const { data: notification, error: insertError } = await adminClient
      .from("notifications")
      .insert({
        title,
        body,
        target_type: target,
        target_user_id: target === "user" ? targetUserId : null,
        story_id: storyId ?? null,
        created_by_admin_id: adminRow.id,
      })
      .select("id")
      .single();
    if (insertError || !notification) {
      return new Response(JSON.stringify({ error: insertError?.message ?? "Insert failed" }), {
        status: 500,
        headers: jsonHeaders,
      });
    }

    if (Array.isArray(storyIds) && storyIds.length > 0) {
      const storyRows = storyIds.map((sid: string, index: number) => ({
        notification_id: notification.id,
        story_id: sid,
        sort_order: index,
      }));
      const { error: storiesError } = await adminClient.from("notification_stories").insert(storyRows);
      if (storiesError) {
        return new Response(JSON.stringify({ error: storiesError.message }), {
          status: 500,
          headers: jsonHeaders,
        });
      }
    }

    let recipientQuery = adminClient.from("profiles").select("id, push_token");
    if (target === "user") {
      recipientQuery = recipientQuery.eq("id", targetUserId);
    } else if (target === "selected") {
      recipientQuery = recipientQuery.in("id", targetUserIds);
    }
    const { data: recipients, error: recipientsError } = await recipientQuery;
    if (recipientsError) {
      return new Response(JSON.stringify({ error: recipientsError.message }), {
        status: 500,
        headers: jsonHeaders,
      });
    }

    const recipientRows = (recipients ?? []).map((r) => ({
      notification_id: notification.id,
      user_id: r.id,
    }));
    if (recipientRows.length > 0) {
      await adminClient.from("notification_recipients").insert(recipientRows);
    }

    const pushTokens = (recipients ?? [])
      .map((r) => r.push_token)
      .filter((token): token is string => !!token && token.startsWith("ExponentPushToken"));

    let pushSent = 0;
    for (let i = 0; i < pushTokens.length; i += 100) {
      const batch = pushTokens.slice(i, i + 100).map((to) => ({
        to,
        title,
        body,
        data: { storyId: storyId ?? null, storyIds: storyIds ?? null, notificationId: notification.id },
      }));
      const res = await fetch(EXPO_PUSH_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json", Accept: "application/json" },
        body: JSON.stringify(batch),
      });
      if (res.ok) pushSent += batch.length;
    }

    return new Response(
      JSON.stringify({ success: true, recipientCount: recipientRows.length, pushSent }),
      { status: 200, headers: jsonHeaders }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: jsonHeaders });
  }
});
