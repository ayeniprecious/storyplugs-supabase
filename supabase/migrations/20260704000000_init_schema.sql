-- StoryPlugs initial schema
-- Tables, enums, RLS policies per product spec section 2.

create extension if not exists "pgcrypto";

-- ========== ENUMS ==========
create type story_category as enum (
  'kindness', 'family', 'faith', 'forgiveness', 'hope', 'community', 'children', 'everyday_heroes'
);

create type content_source as enum ('manual', 'ai_generated');

create type content_status as enum ('draft', 'pending_review', 'approved', 'published', 'archived');

create type admin_role as enum ('editor', 'super_admin');

create type notification_content_type as enum (
  'story_of_day', 'kindness_quote', 'daily_reflection', 'faith_encouragement'
);

-- ========== PROFILES (extends auth.users) ==========
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  notification_time time not null default '08:00',
  notification_types notification_content_type[] not null default '{}',
  push_token text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ========== ADMINS ==========
create table public.admins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role admin_role not null default 'editor',
  created_at timestamptz not null default now(),
  unique (user_id)
);

-- ========== STORIES ==========
create table public.stories (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  image_url text,
  audio_url text,
  category story_category not null,
  reflection_question text,
  daily_lesson text,
  source content_source not null default 'manual',
  status content_status not null default 'draft',
  generated_by_admin_id uuid references public.admins(id) on delete set null,
  approved_by_admin_id uuid references public.admins(id) on delete set null,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ========== QUOTES ==========
create table public.quotes (
  id uuid primary key default gen_random_uuid(),
  text text not null,
  author text,
  status content_status not null default 'draft',
  published_at timestamptz,
  created_at timestamptz not null default now()
);

-- ========== REFLECTIONS ==========
create table public.reflections (
  id uuid primary key default gen_random_uuid(),
  text text not null,
  status content_status not null default 'draft',
  published_at timestamptz,
  created_at timestamptz not null default now()
);

-- ========== NOTIFICATION HEADLINES ==========
create table public.notification_headlines (
  id uuid primary key default gen_random_uuid(),
  story_id uuid references public.stories(id) on delete cascade,
  headline_text text not null,
  scheduled_for timestamptz not null,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

-- ========== FAVORITES ==========
create table public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  story_id uuid not null references public.stories(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, story_id)
);

-- ========== STORY SHARES ==========
create table public.story_shares (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  story_id uuid not null references public.stories(id) on delete cascade,
  platform text,
  created_at timestamptz not null default now()
);

-- ========== STORY VIEWS / COMPLETIONS ==========
create table public.story_views (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  story_id uuid not null references public.stories(id) on delete cascade,
  completed boolean not null default false,
  listened_audio boolean not null default false,
  created_at timestamptz not null default now()
);

-- ========== INDEXES ==========
create index stories_status_idx on public.stories (status);
create index stories_category_idx on public.stories (category);
create index favorites_user_idx on public.favorites (user_id);
create index story_views_user_idx on public.story_views (user_id);
create index story_views_story_idx on public.story_views (story_id);
create index notification_headlines_scheduled_idx on public.notification_headlines (scheduled_for);

-- ========== updated_at trigger helper ==========
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger set_stories_updated_at before update on public.stories
  for each row execute function public.set_updated_at();

-- ========== admin check helpers (security definer so RLS policies can call them) ==========
create or replace function public.is_admin()
returns boolean as $$
  select exists (
    select 1 from public.admins where user_id = auth.uid()
  );
$$ language sql stable security definer set search_path = public;

create or replace function public.is_super_admin()
returns boolean as $$
  select exists (
    select 1 from public.admins where user_id = auth.uid() and role = 'super_admin'
  );
$$ language sql stable security definer set search_path = public;

-- ========== auto-create profile row on signup ==========
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ========== ROW LEVEL SECURITY ==========
alter table public.profiles enable row level security;
alter table public.admins enable row level security;
alter table public.stories enable row level security;
alter table public.quotes enable row level security;
alter table public.reflections enable row level security;
alter table public.notification_headlines enable row level security;
alter table public.favorites enable row level security;
alter table public.story_shares enable row level security;
alter table public.story_views enable row level security;

-- ---- profiles: users manage their own row, admins can read all ----
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

create policy "profiles_select_admin" on public.profiles
  for select using (public.is_admin());

-- ---- admins: only readable/writable by admins; only super_admins manage membership ----
create policy "admins_select_admin" on public.admins
  for select using (public.is_admin());

create policy "admins_write_super_admin" on public.admins
  for all using (public.is_super_admin()) with check (public.is_super_admin());

-- ---- stories: public reads published only; admins full access ----
create policy "stories_select_published" on public.stories
  for select using (status = 'published');

create policy "stories_select_admin" on public.stories
  for select using (public.is_admin());

create policy "stories_insert_admin" on public.stories
  for insert with check (public.is_admin());

create policy "stories_update_admin" on public.stories
  for update using (public.is_admin());

create policy "stories_delete_admin" on public.stories
  for delete using (public.is_admin());

-- ---- quotes ----
create policy "quotes_select_published" on public.quotes
  for select using (status = 'published');

create policy "quotes_all_admin" on public.quotes
  for all using (public.is_admin()) with check (public.is_admin());

-- ---- reflections ----
create policy "reflections_select_published" on public.reflections
  for select using (status = 'published');

create policy "reflections_all_admin" on public.reflections
  for all using (public.is_admin()) with check (public.is_admin());

-- ---- notification_headlines: admin-only, never exposed to end users ----
create policy "notification_headlines_all_admin" on public.notification_headlines
  for all using (public.is_admin()) with check (public.is_admin());

-- ---- favorites: users manage their own, admins can read all ----
create policy "favorites_all_own" on public.favorites
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "favorites_select_admin" on public.favorites
  for select using (public.is_admin());

-- ---- story_shares: users insert/read their own, admins read all ----
create policy "story_shares_insert_own" on public.story_shares
  for insert with check (auth.uid() = user_id);

create policy "story_shares_select_own" on public.story_shares
  for select using (auth.uid() = user_id);

create policy "story_shares_select_admin" on public.story_shares
  for select using (public.is_admin());

-- ---- story_views: users insert/read their own, admins read all ----
create policy "story_views_insert_own" on public.story_views
  for insert with check (auth.uid() = user_id);

create policy "story_views_select_own" on public.story_views
  for select using (auth.uid() = user_id);

create policy "story_views_select_admin" on public.story_views
  for select using (public.is_admin());
