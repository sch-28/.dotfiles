#!/bin/bash

# Extract file and line from URL
URL="$1"
FILE=$(echo "$URL" | sed -n 's/.*file=\([^&]*\).*/\1/p')
LINE=$(echo "$URL" | sed -n 's/.*line=\([^&]*\).*/\1/p')

# Decode URL-encoded path
FILE=$(printf '%b' "${FILE//%/\\x}")

# Use nvr to jump to the file and line
nvr --remote +"${LINE:-1}" "$FILE"
