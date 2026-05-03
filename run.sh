#!/bin/bash
set -e

# Ensure exactly one argument is provided
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <tar|sysext>"
	exit 1
fi

MODE="$1"
PREFIX="/usr/lib/gentoo-prefix/"

echo "Copying overrides"
cd /overrides
find . -type f -print0 | rsync -0 -avP --files-from=- . $PREFIX

emerge --sync
emerge -uDN world

if [ "$MODE" == "tar" ]; then
	echo "Creating tar archive..."
	tar --xattrs --acls --absolute-names -czvf /out/output.tar.gz "$PREFIX"

elif [ "$MODE" == "sysext" ]; then
	echo "Creating systemd-sysext EROFS image..."

	# Create a staging root directory for the sysext
	STAGING_DIR=$(mktemp -d)

	# Create the necessary directory structures
	mkdir -p "${STAGING_DIR}${PREFIX}"
	mkdir -p "${STAGING_DIR}/usr/lib/extension-release.d"

	find "$STAGING_DIR" -type d -exec chmod 0755 {} +

	# Copy the extension-release metadata
	cp /opt/app/extension-release.gentoo-prefix "${STAGING_DIR}/usr/lib/extension-release.d/"

	# Copy the prefix contents into the staging hierarchy
	# Using 'cp -a' to preserve symlinks, permissions, and extended attributes of the payload
	cp -a "${PREFIX}/." "${STAGING_DIR}${PREFIX}/"

	# Build the EROFS image from the staging directory
	mkfs.erofs -z lz4hc /out/gentoo-prefix.raw "$STAGING_DIR"

	# Clean up staging directory
	rm -rf "$STAGING_DIR"

else
	echo "Error: Invalid argument '$MODE'."
	echo "Argument must be either 'tar' or 'sysext'."
	exit 1
fi

echo "Done."
