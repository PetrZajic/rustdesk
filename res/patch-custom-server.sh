#!/usr/bin/env bash
# Bake self-hosted ID server + public key into the client before compile.
# Defaults are for this fork; override with env RENDEZVOUS_SERVER / RS_PUB_KEY
# (e.g. GitHub Actions secrets of the same names).
set -euo pipefail

SERVER="${RENDEZVOUS_SERVER:-}"
KEY="${RS_PUB_KEY:-}"
# Empty GitHub secret values become "" — treat those as unset.
[[ -z "$SERVER" ]] && SERVER="rustdesk.xzajic.cz"
[[ -z "$KEY" ]] && KEY="tIqvrhTFXST5lNDrFUdQ8f34uOI0bIZTdMJwm2UDir8="
CFG="libs/hbb_common/src/config.rs"

if [[ ! -f "$CFG" ]]; then
  echo "error: $CFG not found (did you check out submodules?)" >&2
  exit 1
fi

# Replace stock RustDesk defaults only — refuse to run twice / on unexpected content.
if ! grep -q 'rs-ny\.rustdesk\.com' "$CFG"; then
  echo "warning: default rendezvous host not found in $CFG (already patched?)" >&2
else
  sed -i.bak -e "s|rs-ny\.rustdesk\.com|${SERVER}|g" "$CFG"
fi

if ! grep -q 'OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=' "$CFG"; then
  echo "warning: default RS_PUB_KEY not found in $CFG (already patched?)" >&2
else
  sed -i.bak -e "s|OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=|${KEY}|g" "$CFG"
fi

rm -f "${CFG}.bak"

echo "Patched custom server defaults:"
grep -n 'RENDEZVOUS_SERVERS\|RS_PUB_KEY' "$CFG" | head -5
