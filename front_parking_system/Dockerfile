FROM ubuntu:22.04 AS build

RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash flutter
USER flutter
WORKDIR /home/flutter

RUN git clone https://github.com/flutter/flutter.git -b stable flutter
ENV PATH="/home/flutter/flutter/bin:${PATH}"

RUN flutter precache --web

RUN flutter config --enable-web

RUN flutter doctor -v

WORKDIR /home/flutter/app

COPY --chown=flutter:flutter pubspec.yaml pubspec.lock ./

RUN flutter pub get

COPY --chown=flutter:flutter . .

RUN flutter build web --release

FROM nginx:stable-alpine

RUN apk add --no-cache curl

RUN rm -rf /usr/share/nginx/html/*

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html

RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]