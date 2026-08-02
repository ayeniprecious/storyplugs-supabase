-- Lets the admin "New signup" notification carry a structured snapshot of the
-- new user (display name, email, date of birth, joined time) instead of just
-- plain text, so the mobile client can render a proper detail card.
--
-- Deliberately does NOT touch notify_user() -- that function's body contains
-- the real CRON_SECRET value (substituted directly into the SQL, since
-- Supabase secrets can't be read back out once set), and redeploying it here
-- with the placeholder would silently break push delivery again. Instead,
-- send_welcome_notification() captures notify_user()'s returned notification
-- id and attaches metadata to it in a separate update.

alter table public.notifications
  add column if not exists metadata jsonb;

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
  v_date_of_birth date;
  v_admin record;
  v_admin_notification_id uuid;
begin
  if auth.uid() is null then
    return;
  end if;

  select welcome_notified_at is not null, display_name, date_of_birth
    into v_already_sent, v_display_name, v_date_of_birth
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

  -- Let every admin know a new account just completed signup, with a
  -- structured snapshot of the new user attached as metadata so the mobile
  -- client can render a detail card instead of just the plain text body.
  select email into v_user_email from auth.users where id = auth.uid();

  for v_admin in select user_id from public.admins loop
    select public.notify_user(
      v_admin.user_id,
      'New signup',
      coalesce(v_display_name, v_user_email, 'A new user') || ' just joined StoryPlugs. Grant Premium from Admin -> Users if needed.'
    ) into v_admin_notification_id;

    update public.notifications
    set metadata = jsonb_build_object(
      'type', 'new_signup',
      'display_name', v_display_name,
      'email', v_user_email,
      'date_of_birth', v_date_of_birth,
      'joined_at', now()
    )
    where id = v_admin_notification_id;
  end loop;
end;
$$;
