# Cross-distribution Flatpak

AppCleaner uses the GNOME 50 runtime, bundling its GTK libraries independently of the host distro. Requires a graphical Linux desktop and Flatpak. A bundle is specific to CPU architecture: build on x86_64 for x86_64, and on aarch64 for aarch64. No claim of testing on every distro is made.

## Install a bundle

Install Flatpak using your distribution's software center, then:

```sh
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user ./AppCleaner-x86_64.flatpak
flatpak run io.github.appcleaner.Linux
```

The GNOME runtime must also be available from Flathub. If prompted, allow Flatpak to download it. Bundles do not include the runtime and first installation needs network access.

## Build from source

On any build host with Cargo and Flatpak:

```sh
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user --no-related flathub org.flatpak.Builder org.gnome.Sdk//50 org.gnome.Platform//50 org.freedesktop.Sdk.Extension.rust-stable//25.08
./scripts/build-flatpak.sh
```

The script vendors the Cargo.lock dependencies, builds offline in the SDK, and writes `dist/AppCleaner-$(uname -m).flatpak`. Vendored source and build directories are ignored by Git. No native host GTK development packages are required. Cargo and the Flatpak SDK Rust compiler must support Rust 2024 and let chains (Rust 1.88+).

## Host integration and permissions

This is a cleanup utility and needs access to home data folders. The manifest grants home access, explicit access to other Flatpak app data, read-only host system files, and permission for `flatpak-spawn --host`. Host commands are used for read-only package ownership and environment queries, and `gio trash` for the user-confirmed cleanup. No package manager uninstall commands are executed by AppCleaner. Selected folders are sent to the host Trash using `gio trash` with confirmation. This avoids desktop portals that reject folders. The host must have the `gio` utility installed (Debian/Ubuntu: `libglib2.0-bin`; Arch/Fedora/openSUSE: `glib2`). If unavailable or failing, cleanup reports an error and does not permanently delete anything.

Inside Flatpak, AppCleaner uses `HOST_XDG_*_HOME` for host data instead of its own sandbox data. It discovers host launchers through `/run/host/usr`, host Flatpak exports, Snap launchers, and XDG data directories. Custom roots outside home remain ineligible for cleanup. Revoking manifest permissions may reduce discovery or cause Trash operations to fail; there is no permanent-delete fallback.

Package command suggestions support apt/dpkg, pacman, dnf, yum, zypper, and Flatpak. RPM-based immutable hosts with rpm-ostree do not get a guessed removal command for base packages. Other package managers, Snap, AppImage, and Nix can still have launcher-based data cleanup; uninstall them through their own tools.

This is a locally built bundle, not a Flathub listing. The app ID is a local identifier and does not imply a registered GitHub project.

References: [Flatpak sandbox permissions](https://docs.flatpak.org/en/latest/sandbox-permissions.html), [offline Cargo builds](https://github.com/flatpak/flatpak-builder-tools/blob/master/cargo/README.md).
