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

    // Supabase caps an unpaginated .select() at 1000 rows by default -- for "all" this
    // must scale to the entire user base, so page through every row explicitly rather
    // than trusting a single request to return everyone.
    const PAGE_SIZE = 1000;
    const recipients: { id: string; push_token: string | null }[] = [];
    for (let from = 0; ; from += PAGE_SIZE) {
      let pageQuery = adminClient.from("profiles").select("id, push_token").range(from, from + PAGE_SIZE - 1);
      if (target === "user") {
        pageQuery = pageQuery.eq("id", targetUserId);
      } else if (target === "selected") {
        pageQuery = pageQuery.in("id", targetUserIds);
      }
      const { data: page, error: pageError } = await pageQuery;
      if (pageError) {
        return new Response(JSON.stringify({ error: pageError.message }), {
          status: 500,
          headers: jsonHeaders,
        });
      }
      recipients.push(...(page ?? []));
      if (!page || page.length < PAGE_SIZE) break;
    }

    const recipientRows = recipients.map((r) => ({
      notification_id: notification.id,
      user_id: r.id,
    }));
    for (let i = 0; i < recipientRows.length; i += PAGE_SIZE) {
      const { error: recipientsInsertError } = await adminClient
        .from("notification_recipients")
        .insert(recipientRows.slice(i, i + PAGE_SIZE));
      if (recipientsInsertError) {
        return new Response(JSON.stringify({ error: recipientsInsertError.message }), {
          status: 500,
          headers: jsonHeaders,
        });
      }
    }

    const pushTokens = recipients
      .map((r) => r.push_token)
      .filter((token): token is string => !!token && token.startsWith("ExponentPushToken"));

    // A 200 from Expo's API only means the batch was accepted for processing --
    // each individual push still gets its own "ticket" in the response body,
    // and THAT is where real per-recipient failures (bad credentials, revoked
    // token, etc.) actually show up. Checking res.ok alone was silently
    // hiding delivery failures.
    let pushSent = 0;
    const pushErrors: unknown[] = [];
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
      const resBody = await res.json().catch(() => null);
      const tickets = Array.isArray(resBody?.data) ? resBody.data : [];
      for (const ticket of tickets) {
        if (ticket?.status === "ok") pushSent += 1;
        else pushErrors.push(ticket);
      }
      if (tickets.length === 0 && !res.ok) {
        pushErrors.push({ httpStatus: res.status, body: resBody });
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        recipientCount: recipientRows.length,
        pushSent,
        pushErrors: pushErrors.length > 0 ? pushErrors : undefined,
      }),
      { status: 200, headers: jsonHeaders }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: jsonHeaders });
  }
});
