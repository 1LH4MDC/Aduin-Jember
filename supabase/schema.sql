create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  email text not null unique,
  phone text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null,
  author_email text not null,
  title text not null,
  category text not null,
  description text not null,
  photo_url text not null,
  storage_path text,
  latitude double precision not null,
  longitude double precision not null,
  address text not null,
  status text not null default 'pending' check (
    status in ('pending', 'diproses', 'selesai', 'ditolak')
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists reports_user_id_idx on public.reports (user_id);
create index if not exists reports_status_idx on public.reports (status);
create index if not exists reports_created_at_idx on public.reports (created_at desc);

alter table public.profiles enable row level security;
alter table public.reports enable row level security;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, phone, is_admin)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(new.email, '@', 1)),
    new.email,
    coalesce(new.raw_user_meta_data ->> 'phone', ''),
    false
  )
  on conflict (id) do update
    set full_name = excluded.full_name,
        email = excluded.email,
        phone = excluded.phone;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create policy "Users can read own profile"
on public.profiles
for select
using (auth.uid() = id or exists (
  select 1 from public.profiles p where p.id = auth.uid() and p.is_admin
));

create policy "Users can update own profile"
on public.profiles
for update
using (auth.uid() = id or exists (
  select 1 from public.profiles p where p.id = auth.uid() and p.is_admin
))
with check (auth.uid() = id or exists (
  select 1 from public.profiles p where p.id = auth.uid() and p.is_admin
));

create policy "Users can read own reports"
on public.reports
for select
using (user_id = auth.uid() or exists (
  select 1 from public.profiles p where p.id = auth.uid() and p.is_admin
));

create policy "Users can insert own reports"
on public.reports
for insert
with check (user_id = auth.uid());

create policy "Admins can update reports"
on public.reports
for update
using (exists (
  select 1 from public.profiles p where p.id = auth.uid() and p.is_admin
))
with check (exists (
  select 1 from public.profiles p where p.id = auth.uid() and p.is_admin
));

insert into storage.buckets (id, name, public)
values ('foto-laporan', 'foto-laporan', true)
on conflict (id) do nothing;

create policy "Clients can upload report images"
on storage.objects
for insert
with check (
  bucket_id = 'foto-laporan'
  and auth.role() in ('anon', 'authenticated')
);

create policy "Everyone can read report images"
on storage.objects
for select
using (bucket_id = 'foto-laporan');

create policy "Users can update own report images"
on storage.objects
for update
using (bucket_id = 'foto-laporan' and auth.role() = 'authenticated')
with check (bucket_id = 'foto-laporan' and auth.role() = 'authenticated');