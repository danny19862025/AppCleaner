# AppCleaner for Linux

A native Rust / GTK4 desktop utility for reviewing and moving application settings, caches, and local data to the desktop Trash.

## Cross-distribution installation

Use the Flatpak bundle for distributions with Flatpak support. It supplies a common GTK runtime rather than relying on host GTK versions. See [build and installation instructions](packaging/README.md). Native builds below require GTK 4.10 or later.

## Run

Requires Rust and GTK4 development libraries (Arch: `sudo pacman -S rust gtk4`; Debian/Ubuntu: `sudo apt install build-essential libgtk-4-dev pkg-config`).

```sh
cargo run --release
```

Use the sidebar **Theme** selector to switch between Cyan, Dark, and Light. Changes apply immediately and are remembered for the next launch.

Select an application, review the exact paths, tick folders, and choose **Move selected to Trash**. Nothing is preselected. A second dialog lists the selected paths before cleanup. Close the target application before cleaning it. Use the file manager's Trash to restore folders.

The package uninstall command is separate: copy it and review/run it in your terminal. Supports Flatpak IDs and package-owner lookup through pacman, dpkg-query, and rpm, choosing apt, pacman, dnf, yum, or zypper for removal suggestions. AppCleaner never runs privileged commands.

## Scope and limitations

- Discovers `.desktop` launchers in XDG application directories and Flatpak export directories. Apps without launchers are not listed.
- Matches exact desktop IDs and application names (including lowercase variants) under XDG config, cache, and data roots. Flatpak sandbox data is detected through `X-Flatpak`.
- These are candidate matches, not proof of ownership. Review paths carefully; personal files may live in app data. Shared folders, fuzzy matches, and arbitrary executable names are deliberately excluded.
- Only immediate children of data roots resolving inside your home are eligible. Top-level symlinks are excluded; size calculation never follows nested symlinks.
- Size scanning runs in the background and stops after 200,000 entries per folder. Inaccessible/truncated scans are marked partial. Sizes are logical, not actual reclaimable disk allocation.
- Trash errors are reported without falling back to permanent deletion. A multi-folder cleanup can partially succeed.
- Running applications can recreate data. Folder sizes reflect the scan time. Do not run as root.
- Uninstall commands are suggestions; package manager dependency prompts must be reviewed. Snap and AppImage uninstallation are not implemented.

## Development

```sh
cargo fmt --check
cargo test
cargo clippy --all-targets -- -D warnings
```

Reference: [GTK4 Rust documentation](https://gtk-rs.org/gtk4-rs/stable/latest/docs/gtk4/).
