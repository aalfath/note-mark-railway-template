#!/bin/sh
# Railway start script for Note Mark.
#  1. Listen on Railway's PORT and derive PUBLIC_URL from the Railway domain.
#  2. Check AUTH_TOKEN__SECRET is base64 of at least 32 bytes (encode it if it isn't).
#  3. Close public sign-ups and anonymous user search unless the deployer opts in.
#  4. On the first boot only, create the account NOTE_MARK_USERNAME with the
#     generated NOTE_MARK_PASSWORD before the web server accepts a request.
#  5. Size the Go heap to the service's memory limit, then exec the server.
#     Any failure exits non-zero so Railway's ON_FAILURE policy restarts it.
set -eu

export BIND__HOST="${BIND__HOST:-0.0.0.0}"
export BIND__PORT="${PORT:-8080}"
export DATA_PATH="${DATA_PATH:-/data}"

if [ -z "${PUBLIC_URL:-}" ] || [ "${PUBLIC_URL}" = "https://" ]; then
    if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
        PUBLIC_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
    else
        PUBLIC_URL="http://localhost:${BIND__PORT}"
    fi
fi
export PUBLIC_URL="${PUBLIC_URL%/}"

if [ -z "${AUTH_TOKEN__SECRET:-}" ]; then
    echo "ERROR: AUTH_TOKEN__SECRET is empty. Set it to a long random value." >&2
    exit 1
fi
valid_b64=0
if printf '%s' "$AUTH_TOKEN__SECRET" | grep -Eq '^[A-Za-z0-9+/]+={0,2}$' && [ $(( ${#AUTH_TOKEN__SECRET} % 4 )) -eq 0 ]; then
    bytes="$(printf '%s' "$AUTH_TOKEN__SECRET" | base64 -d 2>/dev/null | wc -c)"
    [ "${bytes:-0}" -ge 32 ] && valid_b64=1
fi
if [ "$valid_b64" -ne 1 ]; then
    # Not base64 of 32+ bytes: use the base64 of the raw value instead.
    if [ "${#AUTH_TOKEN__SECRET}" -lt 32 ]; then
        echo "ERROR: AUTH_TOKEN__SECRET is too short (needs at least 32 characters)." >&2
        exit 1
    fi
    AUTH_TOKEN__SECRET="$(printf '%s' "$AUTH_TOKEN__SECRET" | base64 | tr -d '\n')"
fi
export AUTH_TOKEN__SECRET

export ENABLE_INTERNAL_SIGNUP="${ENABLE_INTERNAL_SIGNUP:-false}"
export ENABLE_ANONYMOUS_USER_SEARCH="${ENABLE_ANONYMOUS_USER_SEARCH:-false}"

# Go heap target: 80% of the cgroup memory limit (cgroup v2, then v1).
if [ -z "${GOMEMLIMIT:-}" ]; then
    raw=""
    if [ -r /sys/fs/cgroup/memory.max ]; then raw="$(cat /sys/fs/cgroup/memory.max)"
    elif [ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then raw="$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)"; fi
    if [ -n "$raw" ] && [ "$raw" != "max" ] && [ "$raw" -lt 1099511627776 ]; then
        export GOMEMLIMIT="$(( raw / 1048576 * 8 / 10 ))MiB"
    fi
fi

mkdir -p "$DATA_PATH"
marker="$DATA_PATH/.railway-first-user"
if [ ! -f "$marker" ]; then
    user="${NOTE_MARK_USERNAME:-admin}"
    pass="${NOTE_MARK_PASSWORD:-}"
    if ! printf '%s' "$user" | grep -Eq '^[A-Za-z0-9]{3,30}$'; then
        echo "ERROR: NOTE_MARK_USERNAME must be 3-30 letters or digits." >&2
        exit 1
    fi
    if [ "${#pass}" -lt 8 ]; then
        echo "ERROR: NOTE_MARK_PASSWORD must be at least 8 characters." >&2
        exit 1
    fi
    if /note-mark user add -u "$user" -p "$pass" >/dev/null 2>&1; then
        echo "railway: created the first account '$user'"
    elif /note-mark user set-password -u "$user" -p "$pass" >/dev/null 2>&1; then
        # The account exists from an interrupted first boot: give it the generated password.
        echo "railway: account '$user' already existed; set its password from NOTE_MARK_PASSWORD"
    else
        echo "ERROR: could not create the first account '$user'" >&2
        exit 1
    fi
    date -u +%Y-%m-%dT%H:%M:%SZ > "$marker"
fi

echo "railway: Note Mark on :${BIND__PORT}, PUBLIC_URL=${PUBLIC_URL}, signup=${ENABLE_INTERNAL_SIGNUP}, GOMEMLIMIT=${GOMEMLIMIT:-unset}"
exec /note-mark serve
