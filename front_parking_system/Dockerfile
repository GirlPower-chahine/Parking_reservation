# Étape 1 : Build Flutter Web
FROM ubuntu:22.04 AS build

RUN apt-get update && apt-get install -y \
    curl git wget unzip xz-utils zip libgl1 libglib2.0-0 libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash flutter
USER flutter
WORKDIR /home/flutter

RUN git clone https://github.com/flutter/flutter.git -b stable flutter
ENV PATH="/home/flutter/flutter/bin:${PATH}"

RUN flutter precache --web
RUN flutter config --enable-web

WORKDIR /home/flutter/app
COPY --chown=flutter:flutter . .

RUN flutter pub get
RUN flutter build web --release

# Étape 2 : Serveur NGINX
FROM nginx:stable-alpine

# Supprimer les fichiers html par défaut
RUN rm -rf /usr/share/nginx/html/*

# Utiliser une conf nginx adaptée à Flutter Web
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers Flutter Web
COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
