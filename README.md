# shubenOS 1.0 (Debian 12 base, bootable ISO)
Copyright (c) 2026 shuben / Apelegends. All rights reserved.

Built from scratch with Debian's `live-build`. Output: `shubenOS-1.0-amd64.iso` (BIOS + UEFI).

## Get the ISO (no Linux needed)
1. Make a free GitHub account and create a **public** repository (public = free build minutes and storage).
2. Click **Add file > Upload files**, drag in everything from this folder EXCEPT `build-iso.yml.txt`, and commit.
3. Click **Add file > Create new file**. In the name box type exactly `.github/workflows/build-iso.yml` (typing the slashes makes the folders). Open `build-iso.yml.txt` in Notepad, copy everything, paste it into the big box, and commit.
4. Open the **Actions** tab, pick **Build shubenOS ISO**, click **Run workflow**.
5. After roughly 30-60 minutes, open the finished run and download **shubenOS-1.0-amd64-iso**. Unzip it to get the `.iso`.
6. If the run fails, download the **build-log** artifact and send me the last 50 lines.

(Alternative: Docker Desktop on Windows -> `docker run --rm --privileged -v "%cd%":/work -w /work debian:bookworm bash build.sh`)

## Use it
- Try it first in VirtualBox/VMware (4 GB RAM, enable EFI) or write it to a USB stick with Rufus (DD mode) or balenaEtcher.
- Boot menu: Start (live) / **Install / Dual-boot** / Safe graphics / Run from RAM / Boot Windows / Firmware settings.
- **Install / Dual-boot** opens the Calamares installer. Choose manual partitioning to pick the exact partition, or "install alongside" to shrink an existing one. NTFS, FAT32, exFAT, ext4, btrfs and GPT/MBR are supported. The installed GRUB lists Windows automatically (os-prober).
- Back up your data before installing next to Windows.

## What's in it
- Desktop: Openbox + Arc dark theme + Papirus icons, Windows-style bottom taskbar and start menu (Super+Space), Plank dock with launch-bounce and hover-zoom animation, custom wallpaper and login screen.
- Terminal: after any failed command it prints why it failed and how to fix it (based on the exit code and the command you typed).
- Intel and AMD: microcode, open GPU drivers (Mesa/RADV/ANV), Vulkan, hardware video decode, GameMode, MangoHud, Lutris.
- Wi-Fi: all Debian Wi-Fi/Bluetooth firmware (Intel, Realtek, Atheros, Broadcom brcm80211, Marvell, MediaTek/Ralink) plus a helper that unblocks radios and writes /var/log/shuben-wifi.log.

## Licensing note
The ISO contains GPL software from Debian. If you distribute it, you must also offer the corresponding source.
