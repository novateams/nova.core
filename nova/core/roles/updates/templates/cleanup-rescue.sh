#!/bin/bash

set -eo pipefail

cd /boot

# Used only to detect if there are any rescue images to remove for task to be marked as changed.
find . -maxdepth 1 -type f -name 'initramfs-0-rescue-*' -printf '%T@ %f\n' \
	| sort -nr \
	| awk 'NR > {{ updates_redhat_family_nr_of_kernels_to_keep }} { print $2 }'

# Sorting the rescue images by modification time and removing all but the latest {{ updates_redhat_family_nr_of_kernels_to_keep }} ones.
find . -maxdepth 1 -type f -name 'initramfs-0-rescue-*' -printf '%T@ %f\n' \
	| sort -nr \
	| awk 'NR > {{ updates_redhat_family_nr_of_kernels_to_keep }} { print $2 }' \
	| xargs -r rm -f

# Sorting the rescue image vmlinuz files by modification time and removing all but the latest {{ updates_redhat_family_nr_of_kernels_to_keep }} ones.
find . -maxdepth 1 -type f -name 'vmlinuz-0-rescue-*' -printf '%T@ %f\n' \
	| sort -nr \
	| awk 'NR > {{ updates_redhat_family_nr_of_kernels_to_keep }} { print $2 }' \
	| xargs -r rm -f

# Sorting the hidden rescue image vmlinuz files by modification time and removing all but the latest {{ updates_redhat_family_nr_of_kernels_to_keep }} ones.
find . -maxdepth 1 -type f -name '.vmlinuz-0-rescue-*' -printf '%T@ %f\n' \
	| sort -nr \
	| awk 'NR > {{ updates_redhat_family_nr_of_kernels_to_keep }} { print $2 }' \
	| xargs -r rm -f
