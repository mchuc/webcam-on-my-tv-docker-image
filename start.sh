#!/bin/bash

# Ustawienia domyślne
MULTICAST=${MULTICAST:-"235.206.241.161"}
PORT=${PORT:-34048}
PLAYPATH=${PLAYPATH:-""}  # Domyślnie brak playpath

# Jeśli podano PLAYPATH (RTSP), konwertuj na HLS
if [ -n "$PLAYPATH" ]; then
    echo "Uruchamianie konwersji RTSP: $PLAYPATH do HLS playlist.m3u8"
    ffmpeg -i "$PLAYPATH" \
    -metadata title="webcam on my TV by Marcin Chuć" \
    -c:v copy \
    -f hls \
    -hls_time 10 \
    -hls_list_size 10 \
    -hls_flags delete_segments \
    /var/www/html/stream/playlist.m3u8 &
else
    # Sprawdź, czy MULTICAST i PORT są ustawione
    if [ -z "$MULTICAST" ]; then
        echo "MULTICAST nie jest ustawiony! Ustaw wartość zmiennej środowiskowej MULTICAST."
        exit 1
    fi

    echo "Uruchamianie konwersji multicast: udp://@$MULTICAST:$PORT do HLS playlist.m3u8"
    ffmpeg -i "udp://@$MULTICAST:$PORT" \
        -metadata title="webcam on my TV by Marcin Chuć" \
        -c:v copy \
        -f hls \
        -hls_time 10 \
        -hls_list_size 20 \
        -hls_flags delete_segments \
        /var/www/html/stream/playlist.m3u8 &
fi

# Uruchom NGINX
echo "Uruchamianie NGINX"
nginx -g 'daemon off;'
