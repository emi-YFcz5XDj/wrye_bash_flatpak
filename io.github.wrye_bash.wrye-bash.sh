#!/bin/sh
[ ! -e "$XDG_CONFIG_HOME"/bash.ini ] &&
	install -Dm644 /app/share/wrye-bash/bash_default.ini "$XDG_CONFIG_HOME"/bash.ini
[ ! -e "$XDG_CONFIG_HOME"/boot-settings.toml ] &&
	install -Dm644 /app/share/wrye-bash/boot-settings_default.toml "$XDG_CONFIG_HOME"/boot-settings.toml

# Workaround NVIDIA bug https://bugs.webkit.org/show_bug.cgi?id=259644
grep -q org.freedesktop.Platform.GL.nvidia /.flatpak-info && export WEBKIT_DISABLE_DMABUF_RENDERER=1
exec python "/app/share/wrye-bash/Wrye Bash Launcher.pyw" "$@"