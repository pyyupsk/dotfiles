#!/bin/bash

# Configuration variables for high video and audio quality
VIDEO_EXTENSION="mp4"          # MP4 container for broad compatibility
VIDEO_CODEC="libx265"          # Software-based H.265 (better quality)
AUDIO_CODEC="libopus"          # Opus for high-quality audio
FRAME_RATE="60"                # 60fps for smoother video (you can adjust as needed)

# Recording directory and file naming
RECORD_DIR="$HOME/Videos"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
FILENAME="recording_${TIMESTAMP}.${VIDEO_EXTENSION}"
FILEPATH="$RECORD_DIR/$FILENAME"

# Ensure the recording directory exists
mkdir -p "$RECORD_DIR"

# Check if wf-recorder is running
if pgrep -x "wf-recorder" > /dev/null; then
    pkill -x "wf-recorder"
    notify-send "Screen Recorder" "Recording stopped. File saved: $FILEPATH"
else
    # Start recording if wf-recorder is installed
    if command -v wf-recorder &>/dev/null; then
        wf-recorder \
            -c "$VIDEO_CODEC" \
            -r "$FRAME_RATE" \
            -f "$FILEPATH" \
            -a -C "$AUDIO_CODEC" \
            -D & # Record continuously without damage optimization
        notify-send "Screen Recorder" "Recording started."
    else
        notify-send "Screen Recorder" "Error: wf-recorder is not installed."
    fi
fi
