#!/bin/bash

# Ustawienia domyślne
MULTICAST=${MULTICAST:-"235.206.241.161"}
PORT=${PORT:-34048}
PLAYPATH=${PLAYPATH:-""}  # Lista RTSP, np. "rtsp://stream1|rtsp://stream2"
BUFFER_TIME=${BUFFER_TIME:-10}  # Domyślny bufor danych
BUFFER_PARTS=${BUFFER_PARTS:-3}  # Ile części
RECONNECT_TIME=${RECONNECT_TIME:-10} # Za ile się podłączyć

# Rozdzielenie zmiennych na tablice, usuwając końcowe separatory
IFS='|' read -r -a multicast_array <<< "${MULTICAST%|}"
IFS='|' read -r -a playpath_array <<< "${PLAYPATH%|}"

# Funkcja do uruchamiania ffmpeg dla multicast
run_multicast_stream() {
    local multicast=$1
    local index=$2
    local output_path="/var/www/html/stream/playlist_$index.m3u8"

    echo "Uruchamianie konwersji multicast: udp://@$multicast:$PORT do HLS $output_path"
    ffmpeg -i "udp://@$multicast:$PORT" \
        -metadata title="Multicast Stream $index :: webcam on my TV by M. Chuć" \
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
        "$output_path" \
        2>> "/var/log/ffmpeg_multicast_$index.log" &
}

# Funkcja do uruchamiania ffmpeg dla playpath
run_playpath_stream() {
    local playpath=$1
    local index=$2
    local output_path="/var/www/html/stream/playlist_$index.m3u8"

    echo "Uruchamianie konwersji RTSP: $playpath do HLS $output_path"
    ffmpeg -i "$playpath" \
        -metadata title="Playpath Stream $index :: webcam on my TV by M. Chuć" \
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
        "$output_path" \
        2>> "/var/log/ffmpeg_playpath_$index.log" &
}

# Priorytet: PLAYPATH > MULTICAST
if [ ${#playpath_array[@]} -gt 0 ]; then
    echo "PLAYPATH ustawione. Ignoruję MULTICAST."
    for i in "${!playpath_array[@]}"; do
        run_playpath_stream "${playpath_array[$i]}" "$i"
    done
elif [ ${#multicast_array[@]} -gt 0 ]; then
    echo "Uruchamianie dla MULTICAST, ponieważ PLAYPATH nie jest ustawione."
    for i in "${!multicast_array[@]}"; do
        run_multicast_stream "${multicast_array[$i]}" "$i"
    done
else
    echo "Brak ustawionych strumieni w PLAYPATH ani MULTICAST."
    exit 1
fi

# Uruchomienie NGINX
echo "Uruchamianie NGINX"
nginx -g 'daemon off;'

