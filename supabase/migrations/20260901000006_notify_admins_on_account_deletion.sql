-- Mirrors send_welcome_notification()'s admin-loop for the opposite event:
-- notifies every admin when a user deletes their account, with the same
-- structured metadata (display_name, email, date_of_birth) so the mobile
-- client renders the same detail card it already uses for "New signup".
--
-- Takes explicit parameters rather than reading auth.uid()/profiles, because
-- by the time this can safely run, the delete-account edge function is about
-- to (or already did) call auth.admin.deleteUser() -- which cascades and
-- wipes the profiles row. The edge function captures the snapshot first and
-- passes it in here. Called with the service role client, so no auth.uid()
-- context exists anyway.

create or replace function public.notify_admins_on_account_deletion(
  p_display_name text,
  p_email text,
  p_date_of_birth date
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_admin record;
  v_notification_id uuid;
begin
  for v_admin in select user_id from public.admins loop
    select public.notify_user(
      v_admin.user_id,
      'Account deleted',
      coalesce(p_display_name, p_email, 'A user') || ' deleted their account.'
    ) into v_notification_id;

    update public.notifications
    set metadata = jsonb_build_object(
      'type', 'account_deleted',
      'display_name', p_display_name,
      'email', p_email,
      'date_of_birth', p_date_of_birth,
      'deleted_at', now()
    )
    where id = v_notification_id;
  end loop;
end;
$$;
