#!/bin/bash

# Check all WAV files in the given folder (default: current folder)
# Usage:
#   ./check_wav_format.sh [--fix] [directory]

FIX=false
TARGET_DIR="."

if [[ "$1" == "--fix" ]]; then
    FIX=true
    if [[ -n "$2" ]]; then
        TARGET_DIR="$2"
    fi
elif [[ -n "$1" ]]; then
    TARGET_DIR="$1"
fi

echo "Scanning WAV files in: $TARGET_DIR"
echo "Fix mode: $FIX"

# Check if any WAV files exist
wav_count=$(find "$TARGET_DIR" -type f -iname "*.wav" | wc -l)

if [ "$wav_count" -eq 0 ]; then
    echo "No WAV files found in: $TARGET_DIR"
    exit 0
fi

find "$TARGET_DIR" -type f -iname "*.wav" | while read -r file; do
    # Extract bytes 20-21 (zero-based) = 2 bytes starting from offset 20
    bytes=$(xxd -s 20 -l 2 -p "$file")
    # Convert to decimal (little-endian)
    reversed=$(echo "$bytes" | awk '{ print substr($0,3,2) substr($0,1,2) }')
    dec_value=$((16#$reversed))

    echo "File: $file"
    echo "  wFormatTag = $dec_value (0x$reversed)"

    if [[ $dec_value -ne 1 ]]; then
        echo "  -> Non-PCM format detected."
        if $FIX; then
            echo "  -> Fixing to PCM (0x0001)."
            printf '\x01\x00' | dd of="$file" bs=1 seek=20 count=2 conv=notrunc 2>/dev/null
        fi
    else
        echo "  -> Already PCM."
    fi
done
