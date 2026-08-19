#!/bin/sh
# NETWORKING UTILITIES
# Network-related shell helpers for development workflows

# Optional configuration (set in personal.sh or parent shell):
#   SKILLS_MYIP_URL — URL that returns plain-text public IP
#   Default: http://ipecho.net/plain

SKILLS_MYIP_URL="${SKILLS_MYIP_URL:-http://ipecho.net/plain}"

# Get public IP address with error handling
# Usage: myip
# Returns: Public IP address or error message

# Unalias myip if it exists (may be defined as alias in other shells)
unalias myip 2>/dev/null || true

myip() {
	if ! command -v curl >/dev/null 2>&1; then
		echo "[networking] myip: curl is required but not found" >&2
		return 1
	fi

	if ! curl -fsS "$SKILLS_MYIP_URL" 2>/dev/null; then
		echo "[networking] myip: failed to fetch public IP from $SKILLS_MYIP_URL" >&2
		return 1
	fi
	echo
}
