#!/bin/sh
# Print GPU utilisation. Silently empty on machines without an NVIDIA GPU
# (e.g. the Intel surface/laptop) so polybar shows nothing instead of erroring.
command -v nvidia-smi >/dev/null 2>&1 || { echo ""; exit 0; }

util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null) || { echo ""; exit 0; }
[ -n "$util" ] && echo "%{F#F0C674}GPU %{F-}${util}%" || echo ""
