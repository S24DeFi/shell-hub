#!/bin/bash
# hub.sh — Unified modular entry point for shell utilities
# 
# Alternative to setup.sh: Load all shell functions and aliases without modifying ~/.bashrc/.zshrc
# Useful for: project-level shell configuration, containerized environments, or portable usage
#
# Usage:
#   source /path/to/webui-lib-shellscripts/scripts/hub.sh
#
# This will:
#   1. Detect and export SKILLS_ROOT (directory containing this file)
#   2. Load all .sh scripts in dependency order (helpers.sh first, then alphabetically)
#   3. Make all shell functions and aliases available in current session
#
# Optional configuration (set before sourcing, or in parent shell):
#   SKILLS_ROOT — Path to this directory (auto-detected if not set)
#   SKILLS_GIT_REMOTE — Git remote to use for branch cleanup (default: origin)
#   SKILLS_PROTECTED_BRANCHES — Space-separated branch names to never delete (default: master main)
#   SKILLS_MYIP_URL — URL endpoint for myip function (default: http://ipecho.net/plain)

# --- Resolve skills repo root (directory containing this file) ------
# Zsh branch uses eval so Bash never parses ${(%):-%x}. Check Zsh first when sourced from Zsh.
if [ -z "${SKILLS_ROOT:-}" ]; then
	if [ -n "${ZSH_VERSION:-}" ]; then
		eval 'SKILLS_ROOT="$(cd "$(dirname "${(%):-%x}")" && pwd)"'
	elif [ -n "${BASH_SOURCE[0]:-}" ]; then
		SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	else
		SKILLS_ROOT="$(cd "$(dirname "$0")" && pwd)"
	fi
fi

# --- Load all shell scripts in correct order ------
# helpers.sh MUST load first as other scripts depend on its functions
if [ -f "$SKILLS_ROOT/helpers.sh" ]; then
	# shellcheck source=/dev/null
	. "$SKILLS_ROOT/helpers.sh"
fi

# Load remaining .sh files in alphabetical order
# Use nullglob for shell-safe glob handling (if available)
if [ -n "${BASH_VERSION:-}" ]; then
	shopt -s nullglob 2>/dev/null || true
	for f in "$SKILLS_ROOT"/*.sh; do
		# shellcheck disable=SC1090 # f is a glob-resolved path within SKILLS_ROOT, not attacker-controlled
		[ -f "$f" ] && [ "$(basename "$f")" != "helpers.sh" ] && [ "$(basename "$f")" != "hub.sh" ] && . "$f"
	done
	shopt -u nullglob 2>/dev/null || true
elif [ -n "${ZSH_VERSION:-}" ]; then
	setopt NULL_GLOB 2>/dev/null || true
	for f in "$SKILLS_ROOT"/*.sh; do
		# shellcheck disable=SC1090 # f is a glob-resolved path within SKILLS_ROOT, not attacker-controlled
		[ -f "$f" ] && [ "$(basename "$f")" != "helpers.sh" ] && [ "$(basename "$f")" != "hub.sh" ] && . "$f"
	done
	unsetopt NULL_GLOB 2>/dev/null || true
else
	# Fallback: explicit file checking
	for f in "$SKILLS_ROOT"/*.sh; do
		if [ -f "$f" ] && [ "$(basename "$f")" != "helpers.sh" ] && [ "$(basename "$f")" != "hub.sh" ]; then
			# shellcheck disable=SC1090 # f is a glob-resolved path within SKILLS_ROOT, not attacker-controlled
			. "$f"
		fi
	done
fi

# Export SKILLS_ROOT so child processes can locate this directory if needed
export SKILLS_ROOT
