// Automated daily push sender, invoked by pg_cron (NOT by admins or users) once per
// configured time slot ("06:00" | "08:00" | "12:00" | "18:00" | "21:00"). Reads each
// user's saved notification_time + notification_types (set during onboarding /
// Preferences) and sends exactly one personalized notification per user per day.
//
// Deploy via Supabase Dashboard -> Edge Functions -> New Function -> paste this file.
// Turn OFF "Verify JWT" for this function -- pg_cron calls it directly with no user
// session, and it authenticates itself instead via the X-Cron-Secret header checked
// below (set CRON_SECRET as a function secret, matching the value used in the
// cron.schedule() calls).
//
// Call with: { "slot": "06:00" }  (one of the five slot values above)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "Content-Type": "application/json" };
const EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send";
const SLOTS = ["06:00", "08:00", "12:00", "18:00", "21:00"];
// "Anytime" users (notification_time = null) have no slot of their own -- fold them
// into this one run so they still get exactly one daily notification.
const ANYTIME_CARRIER_SLOT = "08:00";

interface Profile {
  id: string;
  push_token: string | null;
  notification_types: string[];
}

function daysSinceEpoch(d: Date) {
  return Math.floor(d.getTime() / 86400000);
}

// Deterministic "pick of the day" -- same row for every invocation on the same
// calendar day (so all slots/groups that touch the same table on the same day would
// agree, and reruns don't reshuffle), cycling through the whole table over time.
// offset lets two content types share one table without always picking the same row.
function pickOfDay<T>(rows: T[], todayIndex: number, offset = 0): T | null {
  if (rows.length === 0) return null;
  return rows[(todayIndex + offset) % rows.length];
}

function excerpt(text: string, max = 140) {
  return text.length > max ? `${text.slice(0, max)}...` : text;
}

Deno.serve(async (req: Request) => {
  try {
    const cronSecret = Deno.env.get("CRON_SECRET");
    if (!cronSecret || req.headers.get("X-Cron-Secret") !== cronSecret) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: jsonHeaders });
    }

    const payload = await req.json().catch(() => null);
    const slot = payload?.slot;
    if (!SLOTS.includes(slot)) {
      return new Response(JSON.stringify({ error: `slot must be one of ${SLOTS.join(", ")}` }), {
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

    const today = new Date().toISOString().slice(0, 10);
    const todayIndex = daysSinceEpoch(new Date());

    // Page through every eligible profile for this slot -- same 1000-row-cap
    // reasoning as send-notification's recipient fetch.
    const PAGE_SIZE = 1000;
    const profiles: Profile[] = [];
    for (let from = 0; ; from += PAGE_SIZE) {
      let query = admin
        .from("profiles")
        .select("id, push_token, notification_types")
        .not("push_token", "is", null)
        .or(`last_notified_date.is.null,last_notified_date.lt.${today}`)
        .range(from, from + PAGE_SIZE - 1);
      query =
        slot === ANYTIME_CARRIER_SLOT
          ? query.or("notification_time.is.null,notification_time.eq." + slot)
          : query.eq("notification_time", slot);
      const { data: page, error } = await query;
      if (error) {
        return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: jsonHeaders });
      }
      profiles.push(...((page as Profile[] | null) ?? []));
      if (!page || page.length < PAGE_SIZE) break;
    }

    // Group users by the one content type they'll see today -- a user who picked
    // several types rotates through them day to day rather than getting multiple
    // pings, and grouping this way means everyone landing on the same type today
    // shares one composed message (and one notifications row), same data shape the
    // admin-authored broadcasts already use.
    const groups = new Map<string, Profile[]>();
    for (const profile of profiles) {
      const types = (profile.notification_types ?? []).slice().sort();
      if (types.length === 0) continue;
      const type = types[todayIndex % types.length];
      const list = groups.get(type) ?? [];
      list.push(profile);
      groups.set(type, list);
    }

    let totalRecipients = 0;
    let totalPushSent = 0;
    const pushErrors: unknown[] = [];

    for (const [type, groupProfiles] of groups) {
      let title = "";
      let body = "";
      let storyId: string | null = null;

      if (type === "story_of_day") {
        const { data } = await admin
          .from("stories")
          .select("id, title, body")
          .eq("status", "published")
          .order("id");
        const story = pickOfDay(data ?? [], todayIndex);
        if (!story) continue;
        title = story.title;
        body = excerpt(story.body);
        storyId = story.id;
      } else if (type === "kindness_quote" || type === "faith_encouragement") {
        const { data } = await admin.from("quotes").select("id, text, author").eq("status", "published").order("id");
        const rows = data ?? [];
        const offset = type === "faith_encouragement" ? Math.floor(rows.length / 2) : 0;
        const quote = pickOfDay(rows, todayIndex, offset);
        if (!quote) continue;
        title = type === "faith_encouragement" ? "Faith Encouragement" : "Kindness Quote";
        body = quote.author ? `"${quote.text}" — ${quote.author}` : `"${quote.text}"`;
      } else if (type === "daily_reflection") {
        const { data } = await admin.from("reflections").select("id, text").eq("status", "published").order("id");
        const reflection = pickOfDay(data ?? [], todayIndex);
        if (!reflection) continue;
        title = "Daily Reflection";
        body = reflection.text;
      } else {
        continue;
      }

      const { data: notification, error: insertError } = await admin
        .from("notifications")
        .insert({ title, body, target_type: "selected", story_id: storyId })
        .select("id")
        .single();
      if (insertError || !notification) {
        pushErrors.push({ type, error: insertError?.message ?? "notification insert failed" });
        continue;
      }

      const recipientRows = groupProfiles.map((p) => ({ notification_id: notification.id, user_id: p.id }));
      for (let i = 0; i < recipientRows.length; i += PAGE_SIZE) {
        await admin.from("notification_recipients").insert(recipientRows.slice(i, i + PAGE_SIZE));
      }
      totalRecipients += recipientRows.length;

      const userIds = groupProfiles.map((p) => p.id);
      for (let i = 0; i < userIds.length; i += PAGE_SIZE) {
        await admin.from("profiles").update({ last_notified_date: today }).in("id", userIds.slice(i, i + PAGE_SIZE));
      }

      const pushTokens = groupProfiles
        .map((p) => p.push_token)
        .filter((t): t is string => !!t && t.startsWith("ExponentPushToken"));
      for (let i = 0; i < pushTokens.length; i += 100) {
        const batch = pushTokens.slice(i, i + 100).map((to) => ({
          to,
          title,
          body,
          data: { storyId, notificationId: notification.id },
        }));
        const res = await fetch(EXPO_PUSH_URL, {
          method: "POST",
          headers: { "Content-Type": "application/json", Accept: "application/json" },
          body: JSON.stringify(batch),
        });
        const resBody = await res.json().catch(() => null);
        const tickets = Array.isArray(resBody?.data) ? resBody.data : [];
        for (const ticket of tickets) {
          if (ticket?.status === "ok") totalPushSent += 1;
          else pushErrors.push(ticket);
        }
        if (tickets.length === 0 && !res.ok) pushErrors.push({ httpStatus: res.status, body: resBody });
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        slot,
        groups: Array.from(groups.keys()),
        totalRecipients,
        totalPushSent,
        pushErrors: pushErrors.length > 0 ? pushErrors : undefined,
      }),
      { status: 200, headers: jsonHeaders }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: jsonHeaders });
  }
});
