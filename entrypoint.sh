#!/bin/bash
PREFIX="/usr/lib/gentoo-prefix"

set -e

# Source environment variables from your prefix setup
source "${PREFIX}/etc/profile"
while IFS= read -r entry; do
	new_entry="$PREFIX$entry"
	[[ ":$PATH:" != *":$new_entry:"* ]] && PATH="$PATH:$new_entry"
done < <(echo "$PATH" | tr ':' '\n')
# Hand off to CMD (or whatever the user passed to `podman run`)
exec "$@"
