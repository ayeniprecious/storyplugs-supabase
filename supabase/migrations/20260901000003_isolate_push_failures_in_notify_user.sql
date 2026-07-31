-- Real bug found live: notify_user()'s net.http_post() call (sending the
-- actual push) had nothing catching a failure -- any exception there (a
-- missing pg_net extension, an unreachable URL, anything) rolled back the
-- ENTIRE calling transaction, including the notifications/notification_
-- recipients rows that should already have been committed, and any flag
-- the caller set beforehand (e.g. send_welcome_notification()'s own
-- welcome_notified_at guard). Confirmed live: two fresh test signups today
-- got zero notification rows at all, for either the user's own welcome
-- message or the new admin signup alert.
--
-- The in-app notification record is the source of truth and must survive
-- regardless of whether the push actually goes out -- wrapping the push
-- call in its own exception handler so a delivery failure can only ever
-- fail silently (best-effort), never take the notification row down with it.
--
-- Also fills in the real project ref (chsqwcfavfbfghxqlnwk) in place of the
-- <PROJECT_REF> placeholder the original migration left unfilled. The
-- <CRON_SECRET> placeholder is still here -- replace it with the exact same
-- value already set as the send-event-notification function's CRON_SECRET
-- secret before running this (Dashboard -> Edge Functions ->
-- send-event-notification -> Secrets). If they don't match, the push send
-- will fail (safely, with this fix) but the in-app notification will still work.

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
  v_function_url text := 'https://chsqwcfavfbfghxqlnwk.supabase.co/functions/v1/send-event-notification';
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

  -- Isolated on purpose: a push-delivery failure here must never roll back
  -- the insert above or bubble up and fail whatever caller triggered this.
  begin
    perform net.http_post(
      url := v_function_url,
      headers := jsonb_build_object('Content-Type', 'application/json', 'X-Cron-Secret', v_cron_secret),
      body := jsonb_build_object('notification_id', v_notification_id, 'user_id', p_user_id)
    );
  exception when others then
    raise warning 'notify_user: push send failed for notification %: %', v_notification_id, sqlerrm;
  end;

  return v_notification_id;
end;
$$;
