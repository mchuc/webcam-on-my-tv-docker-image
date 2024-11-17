FROM debian:bullseye-slim

# Zainstaluj wymagane pakiety (FFmpeg i NGINX)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    nginx \
    curl \
    && apt-get clean

# Utwórz katalog dla plików HLS
RUN mkdir -p /var/www/html/stream

# Skopiuj plik konfiguracyjny NGINX
COPY default_page /etc/nginx/sites-available/default

# Skopiuj stronę HTML
COPY index.html /var/www/html/index.html
# Testuję, czy w ogóle player działa, jeśli nie mam streama...
COPY test.html /var/www/html/test.html

# Skrypt startowy do uruchomienia FFmpeg i NGINX
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Ustaw katalog roboczy
WORKDIR /var/www/html/stream
# Daj możliwość linkowania
VOLUME [ "/var/www/html/stream" ]
# Eksponuj port 8080
EXPOSE 8080

# Uruchomienie skryptu startowego
CMD ["/start.sh"]
