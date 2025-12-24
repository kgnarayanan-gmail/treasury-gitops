#!/bin/sh
set -e

# Set default values
VERSION="${VERSION:-dev}"
BUILD_NUMBER="${BUILD_NUMBER:-local}"
ENVIRONMENT="${ENVIRONMENT:-development}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
GIT_COMMIT="${GIT_COMMIT:-unknown}"

# Substitute placeholders in HTML template
sed -e "s|__VERSION__|${VERSION}|g" \
    -e "s|__BUILD_NUMBER__|${BUILD_NUMBER}|g" \
    -e "s|__ENVIRONMENT__|${ENVIRONMENT}|g" \
    -e "s|__IMAGE_TAG__|${IMAGE_TAG}|g" \
    -e "s|__GIT_COMMIT__|${GIT_COMMIT}|g" \
    /usr/share/nginx/html/index.template.html > /usr/share/nginx/html/index.html

# Execute the main command
exec "$@"
