-- Automated, event-driven notifications: welcome on signup, premium upgrade,
-- Continue Reading hitting 5 stories, streak freeze used, streak milestones
-- (5/10/20/30/50/70/100), and a daily check for streaks that just broke.
--
-- IMPORTANT: replace both placeholders in notify_user() below before running --
--   <CRON_SECRET>   -- the same value already set as scheduled-push-sender's
--                       CRON_SECRET function secret (reused here, no new
--                       secret needed -- just set it again on the new
--                       send-event-notification function once deployed)
--   <PROJECT_REF>   -- your Supabase project ref (from the project URL)
--
-- Deploy send-event-notification (supabase/functions/send-event-notification)
-- via the Dashboard first, with "Verify JWT" off and CRON_SECRET set to that
-- same value, before running this migration.

create extension if not exists pg_net;
create extension if not exists pg_cron;

-- ========== shared helper: create the in-app notification + best-effort push ==========
-- security definer because it's called from trigger contexts running as a
-- regular authenticated user (e.g. a user inserting their own story_views row),
-- and notifications/notification_recipients only allow admin inserts under RLS.
create or replace function public.notify_user(
  p_user_id uuid,
  p_title text,
  p_body text,
  p_story_ids uuid[] default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_notification_id uuid;
  v_function_url text := 'https://<PROJECT_REF>.supabase.co/functions/v1/send-event-notification';
  v_cron_secret text := '<CRON_SECRET>';
  i int;
begin
  insert into public.notifications (title, body, target_type, target_user_id)
  values (p_title, p_body, 'user', p_user_id)
  returning id into v_notification_id;

  insert into public.notification_recipients (notification_id, user_id)
  values (v_notification_id, p_user_id);

  if p_story_ids is not null then
    for i in 1 .. array_length(p_story_ids, 1) loop
      insert into public.notification_stories (notification_id, story_id, sort_order)
      values (v_notification_id, p_story_ids[i], i - 1);
    end loop;
  end if;

  -- Fire-and-forget: pg_net queues this and returns immediately, so a slow or
  -- failed push send never blocks the statement that triggered it. The in-app
  -- notification above already exists regardless of whether this succeeds.
  perform net.http_post(
    url := v_function_url,
    headers := jsonb_build_object('Content-Type', 'application/json', 'X-Cron-Secret', v_cron_secret),
    body := jsonb_build_object('notification_id', v_notification_id, 'user_id', p_user_id)
  );

  return v_notification_id;
end;
$$;

-- ========== 1. Welcome notification on signup ==========
-- Extends the existing handle_new_user() (which creates the profiles row) --
-- one trigger, same as before, no new trigger needed.
create or replace function public.handle_new_user()
returns trigger as $$
declare
  v_app_name text;
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');

  select (value #>> '{}') into v_app_name from public.app_settings where key = 'app_name';

  perform public.notify_user(
    new.id,
    'Welcome to ' || coalesce(v_app_name, 'StoryPlugs') || '!',
    'A story every day, made for you. We''re glad you''re here.'
  );

  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- ========== 2. Premium upgrade ==========
create or replace function public.notify_premium_upgrade()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not old.is_premium and new.is_premium then
    perform public.notify_user(
      new.id,
      'You''re Premium now',
      'Unlimited archive access, offline downloads, mood-matched picks, and custom reader themes are all unlocked. Enjoy!'
    );
  end if;
  return new;
end;
$$;

drop trigger if exists on_profile_premium_upgrade on public.profiles;
create trigger on_profile_premium_upgrade
  after update on public.profiles
  for each row
  when (old.is_premium is distinct from new.is_premium)
  execute function public.notify_premium_upgrade();

-- ========== 3. Continue Reading reaches 5 ==========
create or replace function public.notify_continue_reading_five()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
  v_story_ids uuid[];
begin
  if new.completed or new.user_id is null then
    return new;
  end if;

  select count(*) into v_count
  from public.story_views
  where user_id = new.user_id and completed = false;

  if v_count = 5 then
    select array_agg(story_id) into v_story_ids
    from (
      select story_id from public.story_views
      where user_id = new.user_id and completed = false
      order by created_at desc
      limit 5
    ) recent;

    perform public.notify_user(
      new.user_id,
      '5 stories waiting for you',
      'Your Continue Reading list just hit 5 -- pick one up where you left off.',
      v_story_ids
    );
  end if;

  return new;
end;
$$;

drop trigger if exists on_story_view_continue_reading_check on public.story_views;
create trigger on_story_view_continue_reading_check
  after insert or update on public.story_views
  for each row
  execute function public.notify_continue_reading_five();

-- ========== 4. Streak freeze used ==========
-- Full replace of the existing use_streak_freeze() (see 20260726000000) --
-- identical body, with a notify_user() call added once the freeze succeeds.
create or replace function public.use_streak_freeze()
returns void as $$
declare
  v_yesterday date := current_date - 1;
  v_spent int;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  if not exists (select 1 from public.profiles where id = auth.uid() and is_premium) then
    raise exception 'not_premium';
  end if;

  update public.profiles
  set streak_freezes_available = 2,
      streak_freezes_reset_at = (current_date + interval '1 month')::date
  where id = auth.uid()
    and (streak_freezes_reset_at is null or now() >= streak_freezes_reset_at);

  if exists (
    select 1 from public.reading_activity
    where user_id = auth.uid() and activity_date in (v_yesterday, current_date)
  ) then
    raise exception 'no_gap_to_freeze';
  end if;

  update public.profiles
  set streak_freezes_available = streak_freezes_available - 1
  where id = auth.uid() and streak_freezes_available > 0
  returning streak_freezes_available into v_spent;

  if v_spent is null then
    raise exception 'no_freezes_available';
  end if;

  insert into public.reading_activity (user_id, activity_date, is_freeze)
  values (auth.uid(), v_yesterday, true)
  on conflict (user_id, activity_date) do nothing;

  perform public.notify_user(
    auth.uid(),
    'Streak protected',
    'We used a Streak Freeze to cover yesterday, so your streak stays alive.'
  );
end;
$$ language plpgsql security definer set search_path = public;

-- ========== 5. Streak milestones (5/10/20/30/50/70/100) ==========
create or replace function public.notify_streak_milestone()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_streak int;
begin
  v_streak := public.current_reading_streak(new.user_id);

  if v_streak = any(array[5, 10, 20, 30, 50, 70, 100]) then
    perform public.notify_user(
      new.user_id,
      v_streak::text || '-Day Streak!',
      'You''ve read ' || v_streak::text || ' days in a row. Keep it going!'
    );
  end if;

  return new;
end;
$$;

drop trigger if exists on_reading_activity_streak_milestone on public.reading_activity;
create trigger on_reading_activity_streak_milestone
  after insert on public.reading_activity
  for each row
  execute function public.notify_streak_milestone();

-- ========== 6. Streak lost (daily check -- breaking is detected by absence ==========
-- of activity, so it can't be a trigger; it's the one case here that needs a
-- once-a-day scan, wired to pg_cron below).
alter table public.profiles add column if not exists last_streak_loss_notified_date date;

create or replace function public.check_streak_losses()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
begin
  -- A streak breaks the day current_date - latest_activity first exceeds 1,
  -- i.e. exactly when the last activity was 2 days ago -- same threshold
  -- current_reading_streak() uses to return 0.
  for r in
    select ra.user_id
    from public.reading_activity ra
    join public.profiles p on p.id = ra.user_id
    where p.last_streak_loss_notified_date is distinct from current_date
    group by ra.user_id
    having max(ra.activity_date) = current_date - 2
  loop
    perform public.notify_user(
      r.user_id,
      'Your streak ended',
      'Your reading streak reset today. Every streak starts with day one -- jump back in.'
    );

    update public.profiles
    set last_streak_loss_notified_date = current_date
    where id = r.user_id;
  end loop;
end;
$$;

select cron.schedule(
  'streak-loss-check',
  '0 7 * * *',
  $$ select public.check_streak_losses(); $$
);
