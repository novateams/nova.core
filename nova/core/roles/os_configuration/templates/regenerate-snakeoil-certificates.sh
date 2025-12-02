#!/bin/sh

set -e

# Regenerating snakeoil certificates if make-ssl-cert command is available
# Needs ssl-cert packages installed
if [ -x "$(command -v make-ssl-cert)" ]; then

    make-ssl-cert generate-default-snakeoil --force-overwrite

else

    echo "make-ssl-cert command not found, skipping"

fi

