-- Two real bugs found via live data, not just code review:
--
-- 1. send_welcome_notification() only checked "has this ever fired before",
--    not "was this account actually just created". Any pre-existing account
--    reaching this code path for the first time (the admin's own account,
--    or storyplugs@gmail.com -- both created weeks ago, confirmed via
--    profiles.created_at) got treated as a brand-new signup: it received
--    its own "Welcome to StoryPlugs!" and the admin got a "New signup"
--    alert about it, both false. Fixed by gating the actual sends on the
--    account having been created recently (24h window -- generous enough
--    to cover a delayed email confirmation, tight enough to exclude any
--    account that's existed for even a day). The welcome_notified_at flag
--    is still set unconditionally so this never re-evaluates for that
--    account again, silently, with no notification either way.
--
-- 2. profiles.date_of_birth/gender were only ever saved by a follow-up
--    .update() call in signUpWithEmail() that requires an IMMEDIATE
--    session -- but this project requires email confirmation, so real
--    signups never get an immediate session and that data was silently
--    dropped forever (confirmed: a real deleted account's snapshot showed
--    date_of_birth: null). Fixed at the source: handle_new_user() now
--    reads date_of_birth/gender out of raw_user_meta_data, which IS
--    populated at signUp() time regardless of confirmation status. The
--    mobile client change to actually pass them through raw_user_meta_data
--    ships alongside this migration.

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name, date_of_birth, gender)
  values (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    nullif(new.raw_user_meta_data ->> 'date_of_birth', '')::date,
    new.raw_user_meta_data ->> 'gender'
  );

  return new;
end;
$$ language plpgsql security definer set search_path = public;

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
  v_created_at timestamptz;
  v_admin record;
  v_admin_notification_id uuid;
begin
  if auth.uid() is null then
    return;
  end if;

  select welcome_notified_at is not null, display_name, date_of_birth, created_at
    into v_already_sent, v_display_name, v_date_of_birth, v_created_at
  from public.profiles where id = auth.uid();

  if v_already_sent then
    return;
  end if;

  -- Set the flag before sending so a second call racing in (e.g. a fast
  -- remount) can't double-send while the first call is still in flight.
  -- Set unconditionally -- an existing account hitting this path for the
  -- first time must never fire again either, it just gets no notification.
  update public.profiles set welcome_notified_at = now() where id = auth.uid();

  -- Only a genuinely new signup gets a notification at all. An existing
  -- account whose flag simply was never set before (predates this
  -- feature, or reached Home for the first time long after creation)
  -- stops here, silently, with the flag already claimed above.
  if v_created_at < now() - interval '24 hours' then
    return;
  end if;

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
