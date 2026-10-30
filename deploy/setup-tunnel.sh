#!/bin/sh
# One-time Cloudflare Tunnel setup: log in (opens a browser link), create the tunnel,
# point HOSTNAME at it and write .cloudflared/config.yml for the compose "tunnel" service.
set -e
cd "$(dirname "$0")/.."
TUNNEL_NAME="${TUNNEL_NAME:-pm-timesheet}"
HOSTNAME="${HOSTNAME_TO_ROUTE:-pm.kylelau.ca}"
IMAGE=cloudflare/cloudflared:2025.8.0
DIR="$PWD/.cloudflared"
mkdir -p "$DIR"
cf() { docker run --rm -u 0 -v "$DIR:/root/.cloudflared" "$IMAGE" "$@"; }

[ -f "$DIR/cert.pem" ] || cf tunnel login
cf tunnel info "$TUNNEL_NAME" >/dev/null 2>&1 || cf tunnel create "$TUNNEL_NAME"
TUNNEL_ID=$(cf tunnel list -n "$TUNNEL_NAME" -o json | sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' | head -1)
cf tunnel route dns -f "$TUNNEL_NAME" "$HOSTNAME"

cat > "$DIR/config.yml" <<CFG
tunnel: $TUNNEL_ID
credentials-file: /etc/cloudflared/$TUNNEL_ID.json
ingress:
  - hostname: $HOSTNAME
    service: http://gateway:80
  - service: http_status:404
CFG
chmod 644 "$DIR/config.yml" "$DIR/$TUNNEL_ID.json"
echo "Tunnel $TUNNEL_NAME ($TUNNEL_ID) -> https://$HOSTNAME"
