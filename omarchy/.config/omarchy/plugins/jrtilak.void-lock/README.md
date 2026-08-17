# Void Lock

Terminal-style Omarchy lock screen inspired by `jrTilak/sddm-theme-void`.
It does not ship a fixed color palette; it reads Omarchy's active theme colors
and wallpaper through the normal shell `Color.*` values.

## Install

```bash
omarchy plugin add https://github.com/jrTilak/omarchy-void-lock.git --enable
```

## Features

- Uses Omarchy's stock session-lock and PAM service flow.
- Password unlock with failure feedback and long-password scaling.
- Fingerprint hint when fingerprint authentication is configured.
- Clock, date, host, user, and battery status.
- Sleep, hibernate, shutdown, and reboot actions.
- Mouse wake/focus and keyboard clearing with `Esc` or `Ctrl+U`.

## Notes

This is a lock screen plugin, not an SDDM greeter. The login screen before the desktop starts is still controlled by SDDM.
