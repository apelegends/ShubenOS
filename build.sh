#!/usr/bin/env bash
# shubenOS 1.0 - builds shubenOS-1.0-amd64.iso from scratch with Debian 12's live-build.
# Run as root on Debian 12 (or inside the debian:bookworm Docker image):
#   docker run --rm --privileged -v "$PWD":/work -w /work debian:bookworm bash build.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run as root."; exit 1; }
export DEBIAN_FRONTEND=noninteractive
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

apt-get update
apt-get install -y --no-install-recommends live-build debootstrap squashfs-tools xorriso \
  mtools dosfstools rsync ca-certificates grub-common grub-pc-bin grub-efi-amd64-bin \
  grub-efi-amd64-signed shim-signed isolinux syslinux-common

rm -rf /build && mkdir -p /build && rsync -a "$HERE/live/" /build/
cd /build
chmod +x auto/config config/hooks/normal/* 2>/dev/null || true
lb clean --purge >/dev/null 2>&1 || true
lb config
lb build 2>&1 | tee /build/build.log

ISO=$(find /build -maxdepth 1 -name '*.iso' | head -n1)
[ -n "$ISO" ] || { echo "ERROR: no ISO produced, see build.log"; cp /build/build.log "$HERE/build.log"; exit 1; }
cp "$ISO" "$HERE/shubenOS-1.0-amd64.iso"
cp /build/build.log "$HERE/build.log"
( cd "$HERE" && sha256sum shubenOS-1.0-amd64.iso > shubenOS-1.0-amd64.iso.sha256 )
echo "DONE: $HERE/shubenOS-1.0-amd64.iso"
