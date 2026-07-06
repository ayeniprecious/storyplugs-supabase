# StoryPlugs — Supabase project

This folder holds the Supabase schema (migrations) for StoryPlugs. It is intentionally separate from
both `storyplugs-mobile` (consumer app) and the future admin dashboard, since both apps connect to the
same backend.

## One-time setup

1. Create a project at https://supabase.com/dashboard (free tier is fine to start).
2. From the project dashboard, grab:
   - **Project URL** (Settings → API → Project URL)
   - **anon public key** (Settings → API → Project API keys → `anon` `public`)
   - **service_role key** (same page, `service_role` — treat this as a secret; only used server-side in
     Edge Functions, never shipped to the mobile app or admin app frontend)
3. Link this local project to the remote one:
   ```
   npx supabase login
   npx supabase link --project-ref <your-project-ref>
   ```
   The project ref is the short id in your dashboard URL, e.g. `abcdefghijklmnop`.
4. Push the schema:
   ```
   npx supabase db push
   ```

## Bootstrapping the first admin

Nobody can insert into `admins` through the API (RLS requires you to already be a `super_admin`, which
is the chicken-and-egg problem for the very first one). Sign up once through the app normally, then run
this once in the Supabase SQL Editor (dashboard → SQL Editor), which runs as postgres and bypasses RLS:

```sql
insert into public.admins (user_id, role)
values ('<paste-your-auth.users-uuid-here>', 'super_admin');
```

You can find your user id under Authentication → Users in the dashboard.

## Schema overview

See `supabase/migrations/20260704000000_init_schema.sql` for the full schema. Tables:
`profiles`, `admins`, `stories`, `quotes`, `reflections`, `notification_headlines`, `favorites`,
`story_shares`, `story_views`.

Row Level Security is on for every table:
- Anyone (including anonymous) can `select` content rows where `status = 'published'`.
- `admins` (checked via the `is_admin()` / `is_super_admin()` SQL functions) can read/write everything.
- Users can only read/write their own `profiles`, `favorites`, `story_shares`, `story_views` rows.
- `notification_headlines` is never exposed to end users — admin-only.

## Next steps (not yet built)

- Edge Functions: scheduled push sender, AI story draft generator (Claude API, server-side only).
- `pg_cron` schedule wiring the push-sender Edge Function to the 6/8/12/18/21 send slots.
