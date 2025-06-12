#!/bin/sh
[ ! -e "$XDG_CONFIG_HOME"/bash.ini ] &&
	install -Dm644 /app/share/wrye-bash/bash_default.ini "$XDG_CONFIG_HOME"/bash.ini
[ ! -e "$XDG_CONFIG_HOME"/boot-settings.toml ] &&
	install -Dm644 /app/share/wrye-bash/boot-settings_default.toml "$XDG_CONFIG_HOME"/boot-settings.toml

python "/app/share/wrye-bash/Wrye Bash Launcher.pyw" "$@"