#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Thin wrapper around the Hostinger public API (https://developers.hostinger.com)
# Called by Terraform (infra/app/dns.tf). Needs: curl, jq.
#
# Auth: export HOSTINGER_API_TOKEN=...   (hPanel -> Account -> API -> New token)
#
# Usage:
#   hostinger-dns.sh set-nameservers <domain> <ns1> <ns2> [ns3] [ns4]
#   hostinger-dns.sh upsert-record   <domain> <name> <type> <content> [ttl]
#   hostinger-dns.sh delete-record   <domain> <name> <type>
#   hostinger-dns.sh forward-apex    <domain> <https://target>
#   hostinger-dns.sh delete-forward  <domain>
# -----------------------------------------------------------------------------
set -euo pipefail

API="${HOSTINGER_API_URL:-https://developers.hostinger.com}"

die() { echo "hostinger-dns: $*" >&2; exit 1; }

[[ -n "${HOSTINGER_API_TOKEN:-}" ]] || die "HOSTINGER_API_TOKEN is not set (create one in hPanel -> Account -> API)."
command -v jq   >/dev/null || die "jq is required"
command -v curl >/dev/null || die "curl is required"

# api METHOD PATH [JSON_BODY]
api() {
  local method=$1 path=$2 body=${3:-}
  local args=(-sS --fail-with-body --retry 3 --retry-delay 2 --retry-all-errors
              -X "$method" "${API}${path}"
              -H "Authorization: Bearer ${HOSTINGER_API_TOKEN}"
              -H "Accept: application/json"
              -H "Content-Type: application/json")
  [[ -n "$body" ]] && args+=(--data "$body")
  curl "${args[@]}"
  echo
}

cmd=${1:-}; shift || true

case "$cmd" in
  set-nameservers)
    domain=$1; shift
    (( $# >= 2 )) || die "need at least 2 nameservers"
    # Build {"ns1": "...", "ns2": "...", ...} (strip trailing dots, max 4)
    body=$(printf '%s\n' "$@" | head -n 4 | sed 's/\.$//' | jq -R . | jq -s '
      to_entries | map({key: ("ns" + ((.key + 1) | tostring)), value: .value}) | from_entries')
    echo "Setting nameservers for ${domain}: $(echo "$body" | jq -c .)"
    api PUT "/api/domains/v1/portfolio/${domain}/nameservers" "$body"
    ;;

  upsert-record)
    domain=$1 name=$2 type=$3 content=$4 ttl=${5:-300}
    # overwrite=true replaces existing records with the same name+type only;
    # every other record in the zone is left untouched.
    body=$(jq -n --arg n "$name" --arg t "$type" --arg c "$content" --argjson ttl "$ttl" \
      '{overwrite: true, zone: [{name: $n, type: $t, ttl: $ttl, records: [{content: $c}]}]}')
    echo "Upserting ${type} ${name}.${domain} -> ${content}"
    api PUT "/api/dns/v1/zones/${domain}" "$body"
    ;;

  delete-record)
    domain=$1 name=$2 type=$3
    body=$(jq -n --arg n "$name" --arg t "$type" '{filters: [{name: $n, type: $t}]}')
    echo "Deleting ${type} ${name}.${domain}"
    api DELETE "/api/dns/v1/zones/${domain}" "$body"
    ;;

  forward-apex)
    domain=$1 target=$2
    # Recreate so it's idempotent; a failure here should not break the deploy
    api DELETE "/api/domains/v1/forwarding/${domain}" >/dev/null 2>&1 || true
    body=$(jq -n --arg d "$domain" --arg u "$target" '{domain: $d, redirect_type: "301", redirect_url: $u}')
    echo "Forwarding ${domain} -> ${target}"
    api POST "/api/domains/v1/forwarding" "$body" \
      || echo "WARNING: apex forwarding failed - set it manually in hPanel -> Domains -> Redirect" >&2
    ;;

  delete-forward)
    domain=$1
    api DELETE "/api/domains/v1/forwarding/${domain}"
    ;;

  *)
    sed -n '2,16p' "$0"; exit 1 ;;
esac
