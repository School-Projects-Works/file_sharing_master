# File Net — fully offline / self-hosted deployment

Runs the entire stack on one machine with no internet dependency: Postgres,
Auth, PostgREST, Storage (self-hosted Supabase, minus Edge Functions and
Realtime — this app uses neither), PowerSync, and the built React app behind
nginx.

## First-time setup

```bash
cd docker/self-hosted
cp .env.example .env
# Edit .env — see the comments in that file for how to generate each secret.

docker compose up -d --build
```

Wait for `db` to report healthy (`docker compose ps`), then apply the app's
schema (this is a plain Postgres instance — the same migrations used for
local dev via `supabase db reset` apply here directly):

```bash
docker compose exec -T db psql -U postgres -d postgres < ../../supabase/migrations/20260715104835_filenet_schema.sql
docker compose exec -T db psql -U postgres -d postgres < ../../supabase/migrations/20260715105034_filenet_storage.sql
```

Then set the PowerSync replication role's password to match `.env`
(the migration creates it with a placeholder):

```bash
docker compose exec db psql -U postgres -c "ALTER ROLE powersync_role WITH PASSWORD '<POWERSYNC_DB_PASSWORD from .env>';"
```

Bootstrap the first admin account: register a normal account through the app
at `http://<host>/register`, then run:

```bash
docker compose exec -T db psql -U postgres -d postgres -c "select bootstrap_first_admin('the-email-you-registered@example.com');"
```

For account provisioning (`provision_account`, admin-created office/lecturer
logins) to work, also configure Vault secrets once:

```bash
docker compose exec -T db psql -U postgres -d postgres <<'SQL'
select vault.create_secret('<SERVICE_ROLE_KEY from .env>', 'service_role_key');
select vault.create_secret('http://auth:9999/admin/users', 'gotrue_admin_url');
SQL
```

## Ports

| Service | Purpose |
|---|---|
| `${WEB_PORT}` (default 80) | The app itself |
| `${KONG_HTTP_PORT}` (default 8000) | Supabase API (auth/rest/storage) |
| `${POWERSYNC_PORT}` (default 8080) | PowerSync sync endpoint |
| 8082 (studio, optional) | Database admin UI — comment the `studio` service out of `docker-compose.yml` for a hardened deployment that doesn't expose this on the LAN |

No unified reverse proxy — the client talks to each service on its own port
directly, matching how local development already works.

## What's intentionally not included

- **Edge Functions** — everything is implemented as Postgres functions/RPCs/
  triggers instead (see the migration files); nothing in this app needs Deno.
- **Realtime** — PowerSync handles all live sync over its own logical-
  replication connection to Postgres; Supabase Realtime is unused.
- **Supavisor (connection pooler)** — not needed at this scale; every service
  connects to `db` directly.

## Known limitation

This compose file has been validated for syntax and service wiring but not
yet run through a full live deployment test in this environment (spinning up
a second parallel Supabase stack was out of scope for this pass) — the local
dev setup (`supabase start` + `docker/compose.yaml`) it's derived from *has*
been extensively tested. Treat this as a solid, carefully-derived starting
point, and verify the full flow (register → bootstrap admin → upload → share)
once on real hardware before relying on it.
