#!/usr/bin/env fish
if not test -r io.github.wrye_bash.wrye-bash.yaml
	echo "Not in source directory!"
	exit 1
end

function pip_gen
	../flatpak-builder-tools/pip/flatpak-pip-generator --runtime='org.gnome.Sdk//51' --yaml $argv
end

function gen_script_requirements
	pip_gen setuptools_scm pygit2 --prefer-wheels pygit2 --build-only -o python3-requirements-scripts
	wait
end

function gen_requirements
	pip_gen -r requirements.txt --prefer-wheels PyMuPDF --ignore-installed lxml,requests --cleanup scripts
	wait
end

function gen_taglists
	set -f taglist_version v0.29
	for game in Enderal Fallout3 FalloutNV Fallout4 Morrowind Oblivion Skyrim SkyrimSE Starfield;
		set -lx url https://raw.githubusercontent.com/loot/(string lower $game)/$taglist_version/masterlist.yaml
		# @fish-lsp-disable-next-line 4004
		set -lx dest_filename "$game"_masterlist.yaml
		# @fish-lsp-disable-next-line 4004
		set -lx sha256 (curl -sLo - "$url" | sha256sum | string replace '  -' '')
		set -fa output (
			yq eval -n '[ .type = "file" | .url = env(url) | .dest-filename = env(dest_filename) | .sha256 = env(sha256) ]' |
			string trim -r | string collect -N
		)
	end
	printf %s $output > taglists.yaml
	wait
end

gen_script_requirements
gen_requirements
gen_taglists
