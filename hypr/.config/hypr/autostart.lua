-- The user manager outlives logins: XAUTHORITY is left over from an X session, and the
-- target may still be up from a previous Hyprland, so restart it (plain start is a no-op).
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user unset-environment XAUTHORITY; "
        .. "dbus-update-activation-environment --systemd --all; "
        .. "systemctl --user stop i3-session.target; "
        .. "systemctl --user reset-failed dms.service slack-alert-watch.service; "
        .. "systemctl --user restart hyprland-session.target")
end)

hl.on("hyprland.shutdown", function()
    hl.exec_cmd("systemctl --user stop hyprland-session.target")
end)
