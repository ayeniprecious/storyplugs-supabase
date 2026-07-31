-- Consolidates send_welcome_notification() into its final, confirmed-correct
-- form. Live testing showed the new user's own welcome notification was
-- firing (proving the notify_user() exception-handling fix from
-- 20260901000003 is live) but the admin "New signup" alert was not -- the
-- admin-loop addition from 20260901000002 was apparently never actually
-- applied. This re-applies that same logic in one place so there's no
-- ambiguity about what's live: run this one migration and both halves are
-- guaranteed current.

create or replace function public.send_welcome_notification()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_app_name text;
  v_already_sent boolean;
  v_display_name text;
  v_user_email text;
  v_admin record;
begin
  if auth.uid() is null then
    return;
  end if;

  select welcome_notified_at is not null, display_name
    into v_already_sent, v_display_name
  from public.profiles where id = auth.uid();

  if v_already_sent then
    return;
  end if;

  -- Set the flag before sending so a second call racing in (e.g. a fast
  -- remount) can't double-send while the first call is still in flight.
  update public.profiles set welcome_notified_at = now() where id = auth.uid();

  select (value #>> '{}') into v_app_name from public.app_settings where key = 'app_name';

  perform public.notify_user(
    auth.uid(),
    'Welcome to ' || coalesce(v_app_name, 'StoryPlugs') || '!',
    'A story every day, made for you. We''re glad you''re here.'
  );

  -- Let every admin know a new account just completed signup, with the
  -- new user's name (falling back to their email, then a generic string),
  -- so Premium can be granted manually from Admin -> Users.
  select email into v_user_email from auth.users where id = auth.uid();

  for v_admin in select user_id from public.admins loop
    perform public.notify_user(
      v_admin.user_id,
      'New signup',
      coalesce(v_display_name, v_user_email, 'A new user') || ' just joined StoryPlugs. Grant Premium from Admin -> Users if needed.'
    );
  end loop;
end;
$$;
