# Stage 1: Build the Flutter web application
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for Flutter
RUN useradd -ms /bin/bash flutter
USER flutter
WORKDIR /home/flutter

# Install Flutter as non-root user
RUN git clone https://github.com/flutter/flutter.git -b stable flutter
ENV PATH="/home/flutter/flutter/bin:${PATH}"

# Pre-download development binaries
RUN flutter precache --web

# Enable web support
RUN flutter config --enable-web

# Verify installation
RUN flutter doctor -v

# Create app directory
WORKDIR /home/flutter/app

# Copy pubspec files first for better caching
COPY --chown=flutter:flutter pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY --chown=flutter:flutter . .

# Build for web (without deprecated --web-renderer option)
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built web app
COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]