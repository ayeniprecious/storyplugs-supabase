-- Admin dashboard support: real categories table (replacing the fixed enum), featured/pinned
-- flags, profile gender field, comments + reports (schema ready ahead of mobile UI), and a
-- key/value app_settings table for admin-editable app metadata.

-- ========== CATEGORIES ==========
create table public.categories (
  slug text primary key,
  name text not null,
  icon text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

insert into public.categories (slug, name, sort_order) values
  ('kindness', 'Kindness', 0),
  ('family', 'Family', 1),
  ('faith', 'Faith', 2),
  ('forgiveness', 'Forgiveness', 3),
  ('hope', 'Hope', 4),
  ('community', 'Community', 5),
  ('children', 'Children', 6),
  ('everyday_heroes', 'Everyday Heroes', 7);

alter table public.categories enable row level security;

create policy "categories_select_all" on public.categories
  for select using (true);

create policy "categories_all_admin" on public.categories
  for all using (public.is_admin()) with check (public.is_admin());

-- ---- convert stories.category from the story_category enum to a text FK on categories.slug ----
drop index if exists public.stories_category_idx;

alter table public.stories add column category_new text;
update public.stories set category_new = category::text;
alter table public.stories alter column category_new set not null;
alter table public.stories drop column category;
alter table public.stories rename column category_new to category;
alter table public.stories
  add constraint stories_category_fkey foreign key (category) references public.categories (slug);

create index stories_category_idx on public.stories (category);

drop type public.story_category;

-- ========== STORIES: featured / pinned ==========
alter table public.stories add column is_featured boolean not null default false;
alter table public.stories add column is_pinned boolean not null default false;

-- ========== PROFILES: gender ==========
alter table public.profiles add column gender text;

-- ========== COMMENTS (schema ready ahead of mobile UI) ==========
create table public.comments (
  id uuid primary key default gen_random_uuid(),
  story_id uuid not null references public.stories(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create index comments_story_idx on public.comments (story_id, created_at desc);
create index comments_user_idx on public.comments (user_id);

alter table public.comments enable row level security;

create policy "comments_select_published" on public.comments
  for select using (
    exists (select 1 from public.stories s where s.id = comments.story_id and s.status = 'published')
  );

create policy "comments_insert_own" on public.comments
  for insert with check (
    auth.uid() = user_id
    and exists (select 1 from public.stories s where s.id = story_id and s.status = 'published')
  );

create policy "comments_delete_own" on public.comments
  for delete using (auth.uid() = user_id);

create policy "comments_all_admin" on public.comments
  for all using (public.is_admin()) with check (public.is_admin());

-- ========== REPORTS (schema ready ahead of mobile UI) ==========
create type report_target_type as enum ('story', 'comment', 'user');
create type report_status as enum ('pending', 'reviewed', 'dismissed', 'actioned');

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_user_id uuid references auth.users(id) on delete set null,
  target_type report_target_type not null,
  target_id uuid not null,
  reason text not null,
  status report_status not null default 'pending',
  reviewed_by_admin_id uuid references public.admins(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create index reports_status_idx on public.reports (status);
create index reports_target_idx on public.reports (target_type, target_id);

alter table public.reports enable row level security;

create policy "reports_insert_own" on public.reports
  for insert with check (auth.uid() = reporter_user_id);

create policy "reports_select_own" on public.reports
  for select using (auth.uid() = reporter_user_id);

create policy "reports_all_admin" on public.reports
  for all using (public.is_admin()) with check (public.is_admin());

-- ========== NOTIFICATIONS: allow a 'selected' (multi-user) target ==========
-- Recipient list for 'selected' isn't stored on the notifications row itself; it's derivable
-- from the notification_recipients rows the edge function inserts, same as it already does for 'all'.
alter table public.notifications drop constraint if exists notifications_target_type_check;
alter table public.notifications add constraint notifications_target_type_check
  check (target_type in ('all', 'user', 'selected'));

alter table public.notifications drop constraint if exists notifications_target_user_required;
alter table public.notifications add constraint notifications_target_user_required check (
  (target_type = 'user' and target_user_id is not null) or
  (target_type in ('all', 'selected') and target_user_id is null)
);

-- ========== APP SETTINGS (admin-editable, publicly readable) ==========
create table public.app_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

insert into public.app_settings (key, value) values
  ('app_name', '"StoryPlugs"'),
  ('logo_url', 'null'),
  ('privacy_policy', '""'),
  ('terms_of_service', '""');

create trigger set_app_settings_updated_at before update on public.app_settings
  for each row execute function public.set_updated_at();

alter table public.app_settings enable row level security;

create policy "app_settings_select_all" on public.app_settings
  for select using (true);

create policy "app_settings_all_admin" on public.app_settings
  for all using (public.is_admin()) with check (public.is_admin());

-- ========== APP ASSETS (logo upload from the admin settings page) ==========
insert into storage.buckets (id, name, public)
values ('app-assets', 'app-assets', true)
on conflict (id) do nothing;

create policy "app_assets_public_read" on storage.objects
  for select using (bucket_id = 'app-assets');

create policy "app_assets_admin_write" on storage.objects
  for insert with check (bucket_id = 'app-assets' and public.is_admin());

create policy "app_assets_admin_update" on storage.objects
  for update using (bucket_id = 'app-assets' and public.is_admin());

create policy "app_assets_admin_delete" on storage.objects
  for delete using (bucket_id = 'app-assets' and public.is_admin());
