-- Tracks one row per (user, calendar day) the user opened a story, used to compute
-- reading streaks (current + longest ever) on the home screen.

create table public.reading_activity (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  activity_date date not null,
  created_at timestamptz not null default now(),
  unique (user_id, activity_date)
);

create index reading_activity_user_idx on public.reading_activity (user_id);

alter table public.reading_activity enable row level security;

create policy "reading_activity_insert_own" on public.reading_activity
  for insert with check (auth.uid() = user_id);

create policy "reading_activity_select_own" on public.reading_activity
  for select using (auth.uid() = user_id);
