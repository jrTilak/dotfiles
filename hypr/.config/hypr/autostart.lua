-- Extra autostart processes.

o.exec_on_start("gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")
