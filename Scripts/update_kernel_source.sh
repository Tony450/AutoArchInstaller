#!/bin/bash

set -e                                                                                          # If any command in the script fails, the script will immediately stop executing

build_tmp="/tmp/kernel-source-build"
kernel_flavors=("linux" "linux-lts" "linux-zen" "linux-hardened" "linux-rt" "linux-rt-lts")     # Array of Arch kernels

for pkg in "${kernel_flavors[@]}"; do

    if pacman -Q "$pkg" >/dev/null 2>&1; then                                                   # Check if this specific kernel flavor is installed on the machine

        pkg_version=$(pacman -Q "$pkg" | awk '{print $2}')

        bare_version=$(echo "$pkg_version" | sed 's/\.arch.*//; s/-.*//')                       # Strip release suffixes
        target_file="/usr/src/${pkg}-${bare_version}.tar.xz"

        # Skip if the source file for this exact version already exists
        if [ -f "$target_file" ]; then
            continue
        fi

        rm -rf "$build_tmp" && mkdir -p "$build_tmp" && cd "$build_tmp"

        non_root_user=${SUDO_USER:-username}

        # Clone the repository and force-switch to the specific version tag
        if pkgctl repo clone --protocol=https --switch="$pkg_version" "$pkg"; then
            cd "$pkg"

            chown -R "$non_root_user":"$non_root_user" .

            sudo -u "$non_root_user" makepkg -o

            mkdir -p "/usr/src"

            if ls *.tar.xz >/dev/null 2>&1; then
                cp *.tar.xz "$target_file"
            fi

            for file in /usr/src/"${pkg}"-*.tar.xz; do
                if [ -f "$file" ] && [ "$file" != "$target_file" ]; then                        # If the directory contains the same kernel and it is a different version
                    rm -f "$file"
                fi
            done
        fi
    fi
done

rm -rf "$build_tmp"
