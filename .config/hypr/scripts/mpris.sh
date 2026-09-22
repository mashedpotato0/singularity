#!/bin/bash
ACTION="$1"

# Find active player
PLAYER=$(busctl --user list 2>/dev/null | grep -E "org\.mpris\.MediaPlayer2\." | awk '{print $1}' | head -n 1)

if [ -z "$PLAYER" ]; then
    exit 0
fi

case "$ACTION" in
    play-pause|playpause)
        busctl --user call "$PLAYER" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player PlayPause >/dev/null 2>&1
        ;;
    next)
        busctl --user call "$PLAYER" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player Next >/dev/null 2>&1
        ;;
    previous|prev)
        busctl --user call "$PLAYER" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player Previous >/dev/null 2>&1
        ;;
    stop)
        busctl --user call "$PLAYER" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player Stop >/dev/null 2>&1
        ;;
esac
