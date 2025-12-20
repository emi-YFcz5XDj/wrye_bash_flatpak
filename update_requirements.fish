#!/usr/bin/env fish
if not test -r io.github.wrye_bash.wrye-bash.yaml
	echo "Not in source directory!"
	exit 1
end

function pip_gen
	flatpak run --command=flatpak-pip-generator org.flatpak.Builder --yaml $argv
end
function cargo_gen
	flatpak run --command=flatpak-cargo-generator org.flatpak.Builder --yaml $argv
end

function gen_fetch_requirements
	pip_gen --build-only -o python3-setuptools_scm setuptools_scm
end
function gen_compile_requirements
	curl -sLo cargo-maturin.lock https://raw.githubusercontent.com/PyO3/maturin/refs/tags/v1.9.6/Cargo.lock |
		cargo_gen -o cargo-maturin.yaml cargo-maturin.lock &
	curl -sLo cargo-cryptography.lock https://raw.githubusercontent.com/pyca/cryptography/refs/tags/46.0.3/Cargo.lock |
		cargo_gen -o cargo-cryptography.yaml cargo-cryptography.lock &
	pip_gen --build-only -o python3-setuptools_rust setuptools_rust  &
	pip_gen --build-only -r requirements-scripts.txt &
	wait
end
function gen_requirements
	pip_gen -r requirements.txt --ignore-installed lxml,requests &
	wait
end

function gen_taglists
	set -f taglist_version v0.26
	set -f output
	for game_name in Enderal Fallout3 FalloutNV Fallout4 Morrowind Oblivion Skyrim SkyrimSE Starfield;
		set -l url https://raw.githubusercontent.com/loot/(string lower "$game_name")/"$taglist_version"/masterlist.yaml
		set -l dest_file "$game_name"_masterlist.yaml
		set -l checksum (curl -sLo - "$url" | sha256sum)
		set -fa output (
			podman run --rm --security-opt=no-new-privileges --cap-drop all --network none \
				-e url="$url" -e dest_file="$dest_file" -e checksum="$checksum" docker.io/mikefarah/yq eval -n \
				'[ .type = "file" | .url = env(url) | .dest-filename = env(dest_file) | .sha256 = env(checksum) ]' |
			string collect -N
		)
	end
	echo $output | string replace -r '^ -' '-' | string replace -r '  -$' '' > taglists.yaml # Workaround strange fish behaviour
end

gen_fetch_requirements
gen_compile_requirements
gen_requirements
gen_taglists
