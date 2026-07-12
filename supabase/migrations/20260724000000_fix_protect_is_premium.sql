-- The admin dashboard's setPremium action uses the service_role key to bypass RLS entirely,
-- which is how every other admin mutation in this app works. But protect_is_premium() only
-- allowed the change through when public.is_admin() was true, and is_admin() checks
-- auth.uid() -- which is null for a service_role connection (it isn't tied to any one user's
-- session). So the admin's own "Grant Premium" update was being silently reverted by this
-- same trigger the instant it ran. auth.role() = 'service_role' is the correct check for
-- "this is trusted backend code, not an end user's client."
create or replace function public.protect_is_premium()
returns trigger as $$
begin
  if auth.role() <> 'service_role' and not public.is_admin() and new.is_premium is distinct from old.is_premium then
    new.is_premium := old.is_premium;
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;
