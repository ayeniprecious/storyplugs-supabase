-- Streak Freeze (premium): a limited monthly allowance that backfills a missed day
-- so an existing reading streak doesn't reset. The frozen day is inserted into
-- reading_activity looking like normal activity, so neither streak algorithm --
-- the client's computeStreaks() nor the server's current_reading_streak() -- needs
-- any changes to understand freezes.

alter table public.profiles add column streak_freezes_available int not null default 0;
alter table public.profiles add column streak_freezes_reset_at date;

alter table public.reading_activity add column is_freeze boolean not null default false;

-- profiles_update_own has no column-level restriction (same gap is_premium had before
-- 20260723000000_reader_mode_premium_flag.sql) -- without this, any user could PATCH
-- their own profile row directly and set an arbitrary freeze count, bypassing
-- use_streak_freeze() entirely. The RPC below is security definer, so it can still
-- write these columns despite the revoke -- the revoke only applies to the
-- authenticated role, not the function's execution context.
revoke update (streak_freezes_available, streak_freezes_reset_at) on public.profiles from authenticated;

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

  -- Lazy monthly top-up, as one atomic statement. A never-reset profile has
  -- streak_freezes_reset_at = null, and `now() >= null` is never true in SQL --
  -- guarding that explicitly is required or the top-up would never fire.
  update public.profiles
  set streak_freezes_available = 2,
      streak_freezes_reset_at = (current_date + interval '1 month')::date
  where id = auth.uid()
    and (streak_freezes_reset_at is null or now() >= streak_freezes_reset_at);

  -- Only the single most recent missed day is freezable -- no arbitrary backfill.
  if exists (
    select 1 from public.reading_activity
    where user_id = auth.uid() and activity_date in (v_yesterday, current_date)
  ) then
    raise exception 'no_gap_to_freeze';
  end if;

  -- Atomic spend: decrement and check availability in the same statement, so a
  -- double-tap/retry can't spend the same freeze twice.
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
end;
$$ language plpgsql security definer set search_path = public;
