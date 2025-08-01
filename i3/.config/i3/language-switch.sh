#!/bin/sh

# bindsym $mod+e exec --no-startup-id setxkbmap us -option caps:escape 
# bindsym $mod+d exec --no-startup-id setxkbmap de -variant nodeadkeys -option caps:escape 
german() {
    setxkbmap de -variant nodeadkeys -option caps:escape    
    notify-send "German Keyboard"
}
english() {
    setxkbmap us -option caps:escape
    notify-send "English Keyboard"
}

choice=$(printf 'English\nGerman' | rofi -l 2  -no-custom -dmenu -p "Select Language")
if [ "$choice" = "English" ]; then
    english
elif [ "$choice" = "German" ]; then
    german
else
    echo "Invalid choice"
fi

