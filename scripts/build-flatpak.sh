#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"
if command -v flatpak-builder >/dev/null; then
    builder=(flatpak-builder)
elif flatpak info org.flatpak.Builder >/dev/null 2>&1; then
    builder=(flatpak run org.flatpak.Builder)
else
    echo 'Install flatpak-builder or: flatpak install flathub org.flatpak.Builder' >&2
    exit 1
fi
# Stage only source inputs. Vendor dependencies so the sandbox build needs no network.
stage="$project_root/.flatpak-source"
mkdir -p "$stage/.cargo" "$project_root/dist"
cp Cargo.toml Cargo.lock LICENSE "$stage/"
cp -R src packaging "$stage/"
cargo vendor --locked "$stage/vendor" > /dev/null
cat > "$stage/.cargo/config.toml" <<'CONFIG'
[source.crates-io]
replace-with = "vendored-sources"
[source.vendored-sources]
directory = "vendor"
CONFIG
"${builder[@]}" --user --force-clean --repo="$project_root/.flatpak-repo" \
    "$project_root/.flatpak-build" "$project_root/packaging/io.github.appcleaner.Linux.json"
flatpak build-bundle "$project_root/.flatpak-repo" \
    "$project_root/dist/AppCleaner-$(uname -m).flatpak" io.github.appcleaner.Linux
printf '\nBuilt: %s/dist/AppCleaner-%s.flatpak\n' "$project_root" "$(uname -m)"
