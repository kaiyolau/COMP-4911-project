# Self-hosting with Docker Compose + Cloudflare Tunnel

Runs MySQL, the WildFly backend and the Razor Pages frontend on one machine (e.g. Windows + WSL2
with Docker), served publicly at `https://pm.kylelau.ca` through a Cloudflare Tunnel. No router
ports need to be opened.

1. `cp .env.example .env` and set the two MySQL passwords.
2. `deploy/setup-tunnel.sh` (one time): open the printed link, choose the domain, done.
3. `docker compose up -d --build`

The backend creates the schema on first start and `EmptyDbSeeder` loads the demo data
(see `docs/demo-data.md`; every user's password is `password`). Locally the site is also on
`http://localhost:8088`. Stop with `docker compose down` (add `-v` to wipe the database).
