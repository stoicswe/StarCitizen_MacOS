#!/bin/bash
# Simple pkg-config wrapper for x86_64 SDL2

if [[ "$1" == "--cflags" && "$2" == "sdl2" ]]; then
    echo "-I/usr/local/opt/sdl2/include/SDL2"
elif [[ "$1" == "--libs" && "$2" == "sdl2" ]]; then
    echo "-L/usr/local/opt/sdl2/lib -lSDL2"
elif [[ "$1" == "--exists" && "$2" == "sdl2" ]]; then
    exit 0
else
    # Fall back to regular pkg-config for other packages
    exec /usr/bin/pkg-config "$@"
fi