# Multi-stage build for Treasury CI/CD App
FROM nginx:1.27-alpine

# Install envsubst for template substitution
RUN apk add --no-cache gettext

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy HTML template
COPY src/index.html /usr/share/nginx/html/index.template.html

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Set default environment variables
ENV VERSION=dev \
    BUILD_NUMBER=local \
    ENVIRONMENT=development \
    IMAGE_TAG=latest \
    GIT_COMMIT=unknown

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
