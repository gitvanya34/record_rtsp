#!/bin/bash

RTSP_URL="rtsp://admin:pass@192.168.0.10:554/media/video2"
OUT_DIR="/output"
MAX_SIZE="20G"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$SCRIPT_DIR/output_$(date +%Y-%m-%d_%H-%M-%S)"

mkdir -p "$OUT_DIR"
chmod 755 "$OUT_DIR"

while true; do
  echo "[INFO] starting ffmpeg..."

  ffmpeg -rtsp_transport tcp \
    -fflags nobuffer \
    -flags low_delay \
    -i "$RTSP_URL" \
    -c copy -f segment \
    -segment_time 300 \
    -reset_timestamps 1 \
    -strftime 1 \
    "$OUT_DIR/%Y-%m-%d_%H-%M-%S.ts"

  echo "[WARN] ffmpeg stopped, cleaning..."

  # очистка по размеру
  MAX_KB=$(numfmt --from=iec $MAX_SIZE)

  while [ $(du -s "$OUT_DIR" | awk '{print $1}') -gt $MAX_KB ]; do
    OLDEST=$(ls -t "$OUT_DIR" | tail -1)
    rm -f "$OUT_DIR/$OLDEST"
    echo "[DEL] $OLDEST"
  done

  sleep 5
done
