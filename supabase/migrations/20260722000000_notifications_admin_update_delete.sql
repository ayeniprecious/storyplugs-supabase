-- The original notifications policies only covered select/insert for admins, so
-- editing or deleting a sent notification from the admin dashboard silently
-- did nothing (RLS filtered the row out of the update/delete with no error).
create policy "notifications_update_admin" on public.notifications
  for update using (public.is_admin()) with check (public.is_admin());

create policy "notifications_delete_admin" on public.notifications
  for delete using (public.is_admin());
