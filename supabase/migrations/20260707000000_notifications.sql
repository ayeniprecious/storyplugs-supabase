-- Admin-authored notifications, delivered to either all users or one specific user.
-- Each recipient gets their own row so read/delete state is independent per user.

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  target_type text not null check (target_type in ('all', 'user')),
  target_user_id uuid references auth.users(id) on delete cascade,
  story_id uuid references public.stories(id) on delete set null,
  created_by_admin_id uuid references public.admins(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint notifications_target_user_required check (
    (target_type = 'user' and target_user_id is not null) or
    (target_type = 'all' and target_user_id is null)
  )
);

create table public.notification_recipients (
  id uuid primary key default gen_random_uuid(),
  notification_id uuid not null references public.notifications(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  read boolean not null default false,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  unique (notification_id, user_id)
);

create index notification_recipients_user_idx on public.notification_recipients (user_id, created_at desc);

alter table public.notifications enable row level security;
alter table public.notification_recipients enable row level security;

-- notifications: admins see/write everything; a regular user can see a notification's title/body
-- only if they actually have a recipient row for it (their own copy exists).
create policy "notifications_select_admin" on public.notifications
  for select using (public.is_admin());

create policy "notifications_insert_admin" on public.notifications
  for insert with check (public.is_admin());

create policy "notifications_select_via_recipient" on public.notifications
  for select using (
    exists (
      select 1 from public.notification_recipients nr
      where nr.notification_id = notifications.id and nr.user_id = auth.uid()
    )
  );

-- notification_recipients: users fully manage their own rows (read, mark read, delete);
-- admins can insert rows when fanning out a send; the edge function uses service_role anyway.
create policy "notification_recipients_select_own" on public.notification_recipients
  for select using (auth.uid() = user_id);

create policy "notification_recipients_update_own" on public.notification_recipients
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "notification_recipients_delete_own" on public.notification_recipients
  for delete using (auth.uid() = user_id);

create policy "notification_recipients_select_admin" on public.notification_recipients
  for select using (public.is_admin());

create policy "notification_recipients_insert_admin" on public.notification_recipients
  for insert with check (public.is_admin());
