-- The "5 stories waiting for you" notification could still re-fire too
-- often: every time a user's not-completed count returns to exactly 5 (e.g.
-- they finish 1-2 stories and open 1-2 new ones), it counted as a fresh
-- "crossed into 5" event even though the list barely changed. Now it only
-- notifies again once at least 3 of the 5 stories are different from the
-- set it last notified about -- tracked per user so it also never repeats
-- the exact same 5 stories twice.
alter table public.profiles
  add column if not exists last_continue_reading_notified_story_ids uuid[];

create or replace function public.notify_continue_reading_five()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
  v_story_ids uuid[];
  v_prev_ids uuid[];
  v_overlap_count int;
  v_crossed_into_five boolean;
begin
  if new.completed or new.user_id is null then
    return new;
  end if;

  v_crossed_into_five := (
    TG_OP = 'INSERT'
    or (TG_OP = 'UPDATE' and OLD.completed = true and NEW.completed = false)
  );

  if not v_crossed_into_five then
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

    select last_continue_reading_notified_story_ids into v_prev_ids
    from public.profiles where id = new.user_id;

    select count(*) into v_overlap_count
    from unnest(v_story_ids) as s(story_id)
    where s.story_id = any(coalesce(v_prev_ids, array[]::uuid[]));

    -- 5 stories total, so an overlap of 2 or fewer means at least 3 are
    -- different from last time (and covers "identical list" as overlap = 5,
    -- which is always skipped).
    if v_overlap_count <= 2 then
      perform public.notify_user(
        new.user_id,
        '5 stories waiting for you',
        'Your Continue Reading list just hit 5 -- pick one up where you left off.',
        v_story_ids
      );

      update public.profiles
      set last_continue_reading_notified_story_ids = v_story_ids
      where id = new.user_id;
    end if;
  end if;

  return new;
end;
$$;
