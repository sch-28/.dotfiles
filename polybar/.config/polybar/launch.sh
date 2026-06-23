# Kill any running polybar and WAIT for it to die before relaunching, so
# i3's `exec_always` (mod+shift+r) doesn't stack a new bar each restart.
# pkill/pgrep (procps) are present on NixOS; `killall` (psmisc) is not.
pkill -x polybar 2>/dev/null
while pgrep -x polybar >/dev/null; do sleep 0.3; done
#  if type "xrandr"; then
#   for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#     MONITOR=$m polybar --reload toph &
#   done
# else
#   polybar --reload toph &
# fi

BAR_NAME=main
BAR_CONFIG=/home/$USER/.config/polybar/config

SCREENS=$(xrandr --query | grep " connected" | wc -l)
PRIMARY=$(xrandr --query | grep " connected" | grep "primary" | cut -d" " -f1)
OTHERS=$(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1)

# Launch on primary monitor
MONITOR=$PRIMARY polybar --reload -c $BAR_CONFIG $BAR_NAME &
sleep 1

# If only one screen, quit
if [ $SCREENS -eq 1 ]; then
 exit 0
fi


# Launch on all other monitors
for m in $OTHERS; do
 MONITOR=$m polybar --reload -c $BAR_CONFIG $BAR_NAME &
done
