#!/usr/bin/env fish
if not test -r io.github.wrye_bash.wrye_bash.yaml
	echo "Not in source directory!"
	exit 1
end
curl -Lo cargo-maturin.lock https://raw.githubusercontent.com/PyO3/maturin/refs/tags/v1.8.6/Cargo.lock &
curl -Lo cargo-cryptography.lock https://raw.githubusercontent.com/pyca/cryptography/refs/tags/45.0.3/Cargo.lock &
wait
flatpak run --command=flatpak-pip-generator org.flatpak.Builder --yaml --build-only setuptools-scm &
#flatpak run --command=flatpak-pip-generator org.flatpak.Builder --yaml PyMuPDF==1.25.1
flatpak run --command=flatpak-pip-generator org.flatpak.Builder --yaml --build-only setuptools_rust &
flatpak run --command=flatpak-cargo-generator org.flatpak.Builder --yaml -o cargo-maturin.yaml cargo-maturin.lock &
flatpak run --command=flatpak-cargo-generator org.flatpak.Builder --yaml -o cargo-cryptography.yaml cargo-cryptography.lock &
flatpak run --command=flatpak-pip-generator org.flatpak.Builder --yaml -r requirements.txt &
flatpak run --command=flatpak-pip-generator org.flatpak.Builder --yaml --build-only -r requirements-scripts.txt &
wait
