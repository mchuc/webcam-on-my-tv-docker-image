#!/bin/bash

# Ustawienia domyślne
MULTICAST=${MULTICAST:-"235.206.241.161"}
PORT=${PORT:-34048}

# Sprawdź, czy MULTICAST i PORT są ustawione
if [ -z "$MULTICAST" ]; then
    echo "MULTICAST nie jest ustawiony! Ustaw wartość zmiennej środowiskowej MULTICAST. MULTICAST is not set! Set the value of the MULTICAST environment variable."
    exit 1
fi

# Skonfiguruj pełny adres multicast
INPUT="udp://@$MULTICAST:$PORT"

echo "Uruchamianie FFmpeg z adresem: $INPUT Running FFmpg with address: $INPUT"

# Uruchom FFmpeg do transkodowania multicast -> HLS
ffmpeg -i "$INPUT" \
    -c:v copy \
    -f hls \
    -hls_time 2 \
    -hls_list_size 3 \
    -hls_flags delete_segments \
    /var/www/html/stream/playlist.m3u8 &

# Uruchom NGINX
echo "Uruchomienie NGINX"
nginx -g 'daemon off;'