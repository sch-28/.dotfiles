#!/bin/sh
# Print AMD GPU utilisation. With an iGPU present there are several amdgpu
# cards, so pick the one with the most VRAM (the discrete card). Silently empty
# on machines without amdgpu (e.g. the Intel surface/laptop).
best=0
busy=
for dev in /sys/class/drm/card*/device; do
    [ -r "$dev/gpu_busy_percent" ] || continue
    vram=$(cat "$dev/mem_info_vram_total" 2>/dev/null || echo 0)
    [ "$vram" -gt "$best" ] && best=$vram && busy=$(cat "$dev/gpu_busy_percent")
done
[ -n "$busy" ] && echo "%{F#F0C674}GPU %{F-}${busy}%" || echo ""
