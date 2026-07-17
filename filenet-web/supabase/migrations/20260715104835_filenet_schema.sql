-- File Net schema: profiles, groups, files, sharing, notifications.
-- RLS protects direct client access (PostgREST/RPC); PowerSync replicates via a
-- separate BYPASSRLS role and enforces per-user visibility through sync rules instead.

create extension if not exists pgcrypto;
-- Synchronous HTTP client (blocks in-transaction, unlike the async pg_net worker,
-- which can't be polled for a result inside the same transaction that queued it —
-- verified locally; see provision_account below).
create extension if not exists http;

-- ============================================================================
-- Tables
-- ============================================================================

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text not null default '',
  phone text,
  role text not null default 'lecturer' check (role in ('admin','office','lecturer')),
  status text not null default 'active' check (status in ('active','blocked')),
  must_change_password boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  created_by uuid not null references profiles(id) on delete restrict,
  created_at timestamptz not null default now()
);

-- PowerSync requires every synced table to have a single "id" column (its CRUD
-- queue tracks rows by id) — a composite (group_id, member_id) primary key alone
-- doesn't work: replicated rows come through with no id at all. Matches the
-- id + separate unique-constraint pattern already used on file_shares.
create table group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references groups(id) on delete cascade,
  member_id uuid not null references profiles(id) on delete cascade,
  added_by uuid not null references profiles(id),
  added_at timestamptz not null default now(),
  unique (group_id, member_id)
);

-- files: the shareable "document" identity. The actual blob(s) live in
-- file_versions — a file can have many versions, each independently downloadable.
create table files (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  owner_id uuid not null references profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- No stored version_number: ordering is by created_at, and the UI computes a
-- display rank (ROW_NUMBER() OVER (PARTITION BY file_id ORDER BY created_at)) —
-- avoids a race between two offline devices both computing "next version number"
-- before either has synced.
create table file_versions (
  id uuid primary key default gen_random_uuid(),
  file_id uuid not null references files(id) on delete cascade,
  storage_path text not null unique,
  mime_type text not null default 'application/pdf',
  file_size bigint,
  uploaded_by uuid not null references profiles(id),
  created_at timestamptz not null default now()
);

create table file_shares (
  id uuid primary key default gen_random_uuid(),
  file_id uuid not null references files(id) on delete cascade,
  recipient_id uuid not null references profiles(id) on delete cascade,
  shared_by uuid not null references profiles(id),
  source_group_id uuid references groups(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (file_id, recipient_id)
);

create table notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references profiles(id) on delete cascade,
  type text not null default 'file_shared'
    check (type in ('file_shared','group_added','account_blocked','account_unblocked')),
  title text not null,
  body text,
  file_id uuid references files(id) on delete cascade,
  file_share_id uuid references file_shares(id) on delete cascade,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index idx_file_shares_recipient on file_shares (recipient_id);
create index idx_file_shares_file on file_shares (file_id);
create index idx_group_members_member on group_members (member_id);
create index idx_notifications_recipient on notifications (recipient_id, is_read);
create index idx_files_owner on files (owner_id);
create index idx_file_versions_file on file_versions (file_id, created_at);

-- ============================================================================
-- Helper functions
-- ============================================================================

create function is_admin() returns boolean
language sql stable security definer set search_path = public as
$$ select exists(select 1 from profiles where id = auth.uid() and role = 'admin' and status = 'active') $$;

create function is_active() returns boolean
language sql stable security definer set search_path = public as
$$ select exists(select 1 from profiles where id = auth.uid() and status = 'active') $$;

-- ============================================================================
-- New-user provisioning (self-registration path)
-- ============================================================================

create function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name, phone)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.raw_user_meta_data ->> 'phone'
  );
  return new;
end;
$$;

create trigger trg_handle_new_user
after insert on auth.users
for each row execute function handle_new_user();

-- Blocks non-admins from changing their own role/status/must_change_password.
create function prevent_privilege_escalation() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if is_admin() or current_setting('filenet.bootstrap', true) = 'true' then
    return new;
  end if;
  -- Self-service exception: a user clearing their own forced-password-change flag
  -- (after actually changing their password via Supabase Auth) is safe to allow —
  -- it only ever flips true -> false on the caller's own row, nothing else.
  if new.id = auth.uid()
    and old.must_change_password = true and new.must_change_password = false
    and new.role is not distinct from old.role
    and new.status is not distinct from old.status then
    return new;
  end if;
  if new.role is distinct from old.role
    or new.status is distinct from old.status
    or new.must_change_password is distinct from old.must_change_password then
    raise exception 'Only an admin may change role, status, or must_change_password';
  end if;
  return new;
end;
$$;

create trigger trg_prevent_privilege_escalation
before update on profiles
for each row execute function prevent_privilege_escalation();

-- One-time bootstrap for a fresh deployment with zero admins: without this there is
-- no way to create the first admin, since granting admin itself requires is_admin().
-- Self-limiting: becomes a no-op error the moment any admin exists.
create function bootstrap_first_admin(p_email text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if exists (select 1 from profiles where role = 'admin') then
    raise exception 'An admin already exists; have an existing admin promote this user instead';
  end if;
  perform set_config('filenet.bootstrap', 'true', true);
  update profiles set role = 'admin', must_change_password = false where email = p_email;
  if not found then
    raise exception 'No profile found for email %', p_email;
  end if;
end;
$$;
grant execute on function bootstrap_first_admin(text) to authenticated, anon;

-- ============================================================================
-- Row Level Security
-- ============================================================================

alter table profiles enable row level security;
alter table profiles force row level security;
alter table groups enable row level security;
alter table groups force row level security;
alter table group_members enable row level security;
alter table group_members force row level security;
alter table files enable row level security;
alter table files force row level security;
alter table file_versions enable row level security;
alter table file_versions force row level security;
alter table file_shares enable row level security;
alter table file_shares force row level security;
alter table notifications enable row level security;
alter table notifications force row level security;

-- RLS policies only narrow rows an operation is already permitted to touch — PostgREST
-- connects as `authenticated`/`anon`, which need the base table grant too, or every
-- request fails with "permission denied for table X" before RLS is ever evaluated.
grant usage on schema public to authenticated;
grant select, insert, update, delete on profiles, groups, group_members, files, file_versions, file_shares, notifications to authenticated;

-- profiles: every authenticated user can read all rows (needed for the share/group
-- picker), narrowed to safe columns for non-self/non-admin via profiles_directory below.
create policy profiles_select on profiles for select
  using (true);
create policy profiles_update on profiles for update
  using (id = auth.uid() or is_admin())
  with check (id = auth.uid() or is_admin());
create policy profiles_delete on profiles for delete
  using (is_admin());
-- no insert policy: rows are created only by handle_new_user() / provision_account()

-- Narrow read-only view for user/group pickers (id, full_name, email, role only).
create view profiles_directory with (security_invoker = true) as
  select id, full_name, email, role from profiles;
grant select on profiles_directory to authenticated;

-- Cross-table RLS checks below go through these SECURITY DEFINER helpers rather than
-- plain EXISTS subqueries against the other table. Two tables whose SELECT policies
-- directly reference each other (groups <-> group_members, files <-> file_shares)
-- cause Postgres to raise "infinite recursion detected in policy" (42P17), since
-- evaluating one policy requires evaluating the other, which requires the first again.
-- Confirmed locally. Routing the inner check through a security-definer function
-- (owned by a superuser, so it bypasses RLS on its own lookup) breaks the cycle.
create function is_group_member(p_group_id uuid) returns boolean
language sql stable security definer set search_path = public as
$$ select exists(select 1 from group_members where group_id = p_group_id and member_id = auth.uid()) $$;

create function is_group_creator(p_group_id uuid) returns boolean
language sql stable security definer set search_path = public as
$$ select exists(select 1 from groups where id = p_group_id and created_by = auth.uid()) $$;

create function owns_file(p_file_id uuid) returns boolean
language sql stable security definer set search_path = public as
$$ select exists(select 1 from files where id = p_file_id and owner_id = auth.uid()) $$;

create function file_shared_with_me(p_file_id uuid) returns boolean
language sql stable security definer set search_path = public as
$$ select exists(select 1 from file_shares where file_id = p_file_id and recipient_id = auth.uid()) $$;

-- groups
create policy groups_select on groups for select
  using (is_admin() or created_by = auth.uid() or is_group_member(id));
create policy groups_insert on groups for insert
  with check (is_admin() and created_by = auth.uid());
create policy groups_update on groups for update
  using (is_admin() or created_by = auth.uid())
  with check (is_admin() or created_by = auth.uid());
create policy groups_delete on groups for delete
  using (is_admin() or created_by = auth.uid());

-- group_members
create policy group_members_select on group_members for select
  using (is_admin() or is_group_creator(group_id) or member_id = auth.uid());
create policy group_members_insert on group_members for insert
  with check (is_admin() or is_group_creator(group_id));
create policy group_members_delete on group_members for delete
  using (is_admin() or is_group_creator(group_id));

-- files
create policy files_select on files for select
  using (is_admin() or owner_id = auth.uid() or file_shared_with_me(id));
create policy files_insert on files for insert
  with check (owner_id = auth.uid() and is_active());
create policy files_update on files for update
  using (is_admin() or owner_id = auth.uid())
  with check (is_admin() or owner_id = auth.uid());
create policy files_delete on files for delete
  using (is_admin() or owner_id = auth.uid());

-- file_versions: visibility matches the parent file; only the file's owner or an
-- admin may add a new version (reupload) — shared recipients are read/download only.
create policy file_versions_select on file_versions for select
  using (is_admin() or owns_file(file_id) or file_shared_with_me(file_id));
create policy file_versions_insert on file_versions for insert
  with check ((is_admin() or owns_file(file_id)) and is_active() and uploaded_by = auth.uid());
create policy file_versions_delete on file_versions for delete
  using (is_admin() or owns_file(file_id));

-- file_shares
create policy file_shares_select on file_shares for select
  using (is_admin() or recipient_id = auth.uid() or shared_by = auth.uid() or owns_file(file_id));
create policy file_shares_insert on file_shares for insert
  with check (shared_by = auth.uid() and is_active() and owns_file(file_id));
create policy file_shares_delete on file_shares for delete
  using (is_admin() or shared_by = auth.uid() or owns_file(file_id));

-- notifications: no insert policy for clients — only fn_notify_on_share() (postgres-owned) writes rows
create policy notifications_select on notifications for select
  using (is_admin() or recipient_id = auth.uid());
create policy notifications_update on notifications for update
  using (is_admin() or recipient_id = auth.uid())
  with check (is_admin() or recipient_id = auth.uid());
create policy notifications_delete on notifications for delete
  using (is_admin() or recipient_id = auth.uid());

-- ============================================================================
-- Sharing RPCs + notification trigger (no edge functions)
-- ============================================================================

create function share_file_to_user(p_file_id uuid, p_recipient_id uuid)
returns file_shares
language plpgsql security definer set search_path = public as $$
declare
  result file_shares;
begin
  if not (is_admin() or exists(select 1 from files where id = p_file_id and owner_id = auth.uid())) then
    raise exception 'Not permitted to share this file';
  end if;
  if p_recipient_id = auth.uid() then
    raise exception 'Cannot share a file with yourself';
  end if;

  insert into file_shares (file_id, recipient_id, shared_by)
  values (p_file_id, p_recipient_id, auth.uid())
  on conflict (file_id, recipient_id) do nothing
  returning * into result;

  return result;
end;
$$;
grant execute on function share_file_to_user(uuid, uuid) to authenticated;

create function share_file_to_group(p_file_id uuid, p_group_id uuid)
returns setof file_shares
language plpgsql security definer set search_path = public as $$
begin
  if not (is_admin() or exists(select 1 from files where id = p_file_id and owner_id = auth.uid())) then
    raise exception 'Not permitted to share this file';
  end if;
  if not exists(select 1 from groups where id = p_group_id) then
    raise exception 'Group not found';
  end if;

  return query
    insert into file_shares (file_id, recipient_id, shared_by, source_group_id)
    select p_file_id, gm.member_id, auth.uid(), p_group_id
    from group_members gm
    where gm.group_id = p_group_id and gm.member_id <> auth.uid()
    on conflict (file_id, recipient_id) do nothing
    returning *;
end;
$$;
grant execute on function share_file_to_group(uuid, uuid) to authenticated;

-- Single trigger notifies on every file_shares insert, whichever path created it.
create function fn_notify_on_share() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_file_title text;
  v_sharer_name text;
begin
  select title into v_file_title from files where id = new.file_id;
  select full_name into v_sharer_name from profiles where id = new.shared_by;

  insert into notifications (recipient_id, type, title, body, file_id, file_share_id)
  values (
    new.recipient_id,
    'file_shared',
    'New file shared with you',
    coalesce(v_sharer_name, 'Someone') || ' shared "' || coalesce(v_file_title, 'a file') || '" with you',
    new.file_id,
    new.id
  );
  return new;
end;
$$;

create trigger trg_notify_on_share
after insert on file_shares
for each row execute function fn_notify_on_share();

-- ============================================================================
-- Admin account provisioning (no edge functions)
-- ============================================================================
-- Requires two Vault secrets set up once per deployment by an operator:
--   select vault.create_secret('<service_role_key>', 'service_role_key');
--   select vault.create_secret('<internal auth admin URL, e.g. http://kong:8000/auth/v1/admin/users>', 'gotrue_admin_url');
-- Uses the synchronous `http` extension (blocks in-process, in the same transaction),
-- not pg_net: pg_net queues the request for a separate background worker and the
-- worker can't see it until this transaction commits, so a same-transaction poll for
-- the response deadlocks/times out every time — confirmed against the local stack.
-- The service-role key never has to be shipped to the browser client this way either.

create function provision_account(p_full_name text, p_email text, p_phone text, p_role text)
returns table (profile_id uuid, temp_password text)
language plpgsql security definer set search_path = public, extensions as $$
declare
  v_service_key text;
  v_admin_url text;
  v_password text;
  v_response http_response;
  v_new_user_id uuid;
begin
  if not is_admin() then
    raise exception 'Only an admin may provision accounts';
  end if;
  if p_role not in ('admin','office','lecturer') then
    raise exception 'Invalid role: %', p_role;
  end if;

  select decrypted_secret into v_service_key from vault.decrypted_secrets where name = 'service_role_key';
  select decrypted_secret into v_admin_url from vault.decrypted_secrets where name = 'gotrue_admin_url';
  if v_service_key is null or v_admin_url is null then
    raise exception 'Vault secrets service_role_key / gotrue_admin_url are not configured';
  end if;

  v_password := encode(gen_random_bytes(12), 'base64');

  select * into v_response from http((
    'POST',
    v_admin_url,
    ARRAY[
      http_header('Authorization', 'Bearer ' || v_service_key),
      http_header('apikey', v_service_key)
    ],
    'application/json',
    jsonb_build_object(
      'email', p_email,
      'password', v_password,
      'email_confirm', true,
      'user_metadata', jsonb_build_object('full_name', p_full_name, 'phone', p_phone)
    )::text
  )::http_request);

  if v_response.status >= 300 then
    raise exception 'Failed to create auth user (status %): %', v_response.status, v_response.content;
  end if;

  v_new_user_id := (v_response.content::jsonb ->> 'id')::uuid;

  -- profiles row is auto-created by trg_handle_new_user; patch role + force password change.
  update profiles
  set role = p_role, must_change_password = true, phone = p_phone
  where id = v_new_user_id;

  return query select v_new_user_id, v_password;
end;
$$;
grant execute on function provision_account(text, text, text, text) to authenticated;

-- ============================================================================
-- PowerSync replication role + publication
-- ============================================================================

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'powersync_role') then
    create role powersync_role with replication bypassrls login password 'change_me_in_prod';
  end if;
end
$$;

grant select on all tables in schema public to powersync_role;
alter default privileges in schema public grant select on tables to powersync_role;

drop publication if exists powersync;
create publication powersync for table profiles, groups, group_members, files, file_versions, file_shares, notifications;
