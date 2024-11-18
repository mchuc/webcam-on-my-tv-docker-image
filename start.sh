#!/bin/bash

# Ustawienia domyślne
MULTICAST=${MULTICAST:-"235.206.241.161"}
PORT=${PORT:-34048}
PLAYPATH=${PLAYPATH:-""}  # Domyślnie brak playpath
BUFFER_TIME=${BUFFER_TIME:-10}  # Domyślny bufor danych
BUFFER_PARTS=${BUFFER_PARTS:-3}  # Ile częśći
RECONNECT_TIME=${RECONNECT_TIME:-10} # za ile się podłączyć

# Jeśli podano PLAYPATH (RTSP), konwertuj na HLS
if [ -n "$PLAYPATH" ]; then
    echo "Uruchamianie konwersji RTSP: $PLAYPATH do HLS playlist.m3u8"
    ffmpeg -i "$PLAYPATH" \
        -metadata title="webcam on my TV by Marcin Chuć" \
        -c:v copy \
        -f hls \
        -hls_time ${BUFFER_TIME} \
        -hls_list_size ${BUFFER_PARTS} \
        -hls_flags delete_segments \
        -reconnect 1 \
        -reconnect_at_eof 1 \
        -reconnect_streamed 1 \
        -reconnect_delay_max ${RECONNECT_TIME} \
        -loglevel fatal \
        /var/www/html/stream/playlist.m3u8 \
        2>> /var/log/ffmpeg.log&
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
        -hls_time ${BUFFER_TIME} \
        -hls_list_size ${BUFFER_PARTS} \
        -hls_flags delete_segments \
        -reconnect 1 \
        -reconnect_at_eof 1 \
        -reconnect_streamed 1 \
        -reconnect_delay_max ${RECONNECT_TIME} \
        -loglevel fatal \
        /var/www/html/stream/playlist.m3u8 \
        2>> /var/log/ffmpeg.log&
fi

# Uruchom NGINX
echo "Uruchamianie NGINX"
nginx -g 'daemon off;'
