-- Notifies every admin (push, via the same notify_user() infra already used
-- for user-facing events) whenever a new user completes signup, so Premium
-- can be granted manually from Admin -> Users while real in-app purchases
-- aren't wired up yet. Extends send_welcome_notification() rather than the
-- raw auth.users trigger, since that RPC (see 20260823000000) is already the
-- established "this is a real, completed signup" firing point -- called once
-- from the client the first time a user reaches Home, with its own
-- once-only guard already in place.

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
