#!/bin/bash

# Bar characters
bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
bar_count=${#bars[@]}

status=$(playerctl --player spotify status 2>/dev/null)

if [ "$status" = "Playing" ]; then
    artist=$(playerctl --player spotify metadata artist)
    title=$(playerctl --player spotify metadata title)
    output="${artist} - ${title}"

    # Optional: Truncate long titles
    max_length=40
    if [ ${#output} -gt $max_length ]; then
        output="${output:0:$max_length}..."
    fi

    # Use the current second as a rotating index

    echo "▶ $output"
elif [ "$status" = "Paused" ]; then
    artist=$(playerctl --player spotify metadata artist)
    title=$(playerctl --player spotify metadata title)
    output="${artist} - ${title}"

    # Optional: Truncate long titles
    max_length=40
    if [ ${#output} -gt $max_length ]; then
        output="${output:0:$max_length}..."
    fi

    # Use the current second as a rotating index

    echo "■ $output"
else
    echo ""
fi
