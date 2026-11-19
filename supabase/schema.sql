create table if not exists public.sorteo_admins (
  user_id uuid primary key references auth.users (id) on delete cascade
);

alter table public.sorteo_admins enable row level security;
revoke all on table public.sorteo_admins from anon, authenticated;

create table if not exists public.participants (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 80),
  contact text not null check (char_length(btrim(contact)) between 1 and 120),
  normalized_contact text not null unique,
  registered_at timestamptz not null default now(),
  is_winner boolean not null default false,
  won_at timestamptz,
  constraint winner_timestamp_matches_status
    check ((is_winner and won_at is not null) or (not is_winner and won_at is null))
);

alter table public.participants enable row level security;
grant usage on schema public to anon, authenticated;
grant insert on table public.participants to anon, authenticated;
grant select, update, delete on table public.participants to authenticated;

create or replace function public.is_sorteo_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.sorteo_admins
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_sorteo_admin() from public, anon;
grant execute on function public.is_sorteo_admin() to authenticated;

drop policy if exists "Public can register participants" on public.participants;
create policy "Public can register participants"
  on public.participants
  for insert
  to anon, authenticated
  with check (
    char_length(btrim(name)) between 1 and 80
    and char_length(btrim(contact)) between 1 and 120
    and normalized_contact = lower(btrim(contact))
    and is_winner = false
    and won_at is null
  );

drop policy if exists "Organizers can read participants" on public.participants;
create policy "Organizers can read participants"
  on public.participants
  for select
  to authenticated
  using ((select public.is_sorteo_admin()));

drop policy if exists "Organizers can update participants" on public.participants;
create policy "Organizers can update participants"
  on public.participants
  for update
  to authenticated
  using ((select public.is_sorteo_admin()))
  with check ((select public.is_sorteo_admin()));

drop policy if exists "Organizers can delete participants" on public.participants;
create policy "Organizers can delete participants"
  on public.participants
  for delete
  to authenticated
  using ((select public.is_sorteo_admin()));
