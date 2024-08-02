#!/bin/bash -e

#
# Usage ./populate_sdcard.sh <device-name> <sd-card-device> [Yocto-Deploy-Dir]
#

contains() {
	[[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]] && return 0 || return 1
}

SUPPORTED_DEVICES="smarc-rzg2l smarc-rzv2l vision-ai-rzv2l"

usage_check() {
	if [ -z "$1" ] ; then
		echo "No device-name specified"
		echo "Usage: $0 <device-name> <sd-card-device> [Yocto-Deploy-Dir - defaults to '$DEFAULT_YOCTO_DIR']"
		exit 1
	fi
	if ! contains "$SUPPORTED_DEVICES" "$1" ; then
		echo "Device '$1' unknown; Supported list is '$SUPPORTED_DEVICES'"
		echo "Usage: $0 <device-name> <sd-card-device> [Yocto-Deploy-Dir - defaults to '$DEFAULT_YOCTO_DIR']"
		exit 1
	fi
	if [ -z "$2" ] ; then
		echo "No SD card device provided"
		echo "Usage: $0 <device-name> <sd-card-device> [Yocto-Deploy-Dir - defaults to '$DEFAULT_YOCTO_DIR']"
		exit 1
	fi
	if [ ! -e "$2" ] ; then
		echo "SD-card '$2' device does not exist"
		exit 1
	fi
	if [[ $2 != /dev/sd* ]] && [[ $2 != /dev/mmcblk* ]] ; then
		echo "SD-card '$2' device must be named '/dev/sdX' or '/dev/mmcblkX'"
		exit 1
	fi
	if [ ! -d "$3" ] ; then
		echo "Yocto deploy directory '$3' does not exist"
		exit 1
	fi
}

DEVICE="$1"
DEFAULT_YOCTO_DIR="build/tmp/deploy/images/$DEVICE"
YOCTO_DEPLOY_DIR="${3:-${DEFAULT_YOCTO_DIR}}"

usage_check "$1" "$2" "$YOCTO_DEPLOY_DIR"

WESTON_ROOTFS_IMG_FILE="$YOCTO_DEPLOY_DIR/core-image-weston-$DEVICE.rootfs.tar.bz2"
BSP_ROOTFS_IMG_FILE="$YOCTO_DEPLOY_DIR/core-image-bsp-$DEVICE.rootfs.tar.bz2"

copy_boot_files() {
	local bootdir="$1"
	local dst="$2"

	sudo rm -rf ${dst}/*
	for file in ${bootdir}/* ; do
		echo "Copying '$file'"
		sudo cp $file ${dst}/
	done
}

untar_roofs() {
	local dst="$1"
	local rootfs_img_file

	if [ -f "$WESTON_ROOTFS_IMG_FILE" ] ; then
		rootfs_img_file="$WESTON_ROOTFS_IMG_FILE"
	else
		rootfs_img_file="$BSP_ROOTFS_IMG_FILE"
	fi

	echo "Unpacking rootfs file '$rootfs_img_file'"

	sudo rm -rf ${dst}/*
	sudo tar -xf "$rootfs_img_file" -C "$dst"
}

populate_sd_card_single_rootfs() {
	local devname="$1"
	local PSUF
	local TMP="/tmp"

	local mount_dir1="${TMP}/mount_work1/"

	mkdir -p ${mount_dir1}

	if [[ $devname == /dev/mmcblk* ]] ; then
		PSUF=p
	fi

	echo == Unmounting partitions first ==
	sudo umount ${devname}${PSUF}1 &> /dev/null || true

	# Populate rootfs
	echo "== Populating rootfs partition '${devname}${PSUF}1' =="
	sudo mount ${devname}${PSUF}1 ${mount_dir1}
	untar_roofs "${mount_dir1}"

	echo "== Syncing... =="

	sudo sync

	echo == Unmounting partitions \(almost done\) ==
	sudo umount ${devname}${PSUF}1

	echo "== Done... =="
}
populate_sd_card_rootfs() {
	local devname="$1"
	local PSUF
	local TMP="/tmp"

	local mount_dir1="${TMP}/mount_work1/"

	mkdir -p ${mount_dir1}

	if [[ $devname == /dev/mmcblk* ]] ; then
		PSUF=p
	fi

	echo == Unmounting partitions first ==
	sudo umount ${devname}${PSUF}1 &> /dev/null || true

	# Populate rootfs
	echo "== Populating rootfs partition '${devname}${PSUF}1' =="
	sudo mount ${devname}${PSUF}1 ${mount_dir1}
	untar_roofs "${mount_dir1}"

	echo "== Syncing... =="

	sudo sync

	echo == Unmounting partitions \(almost done\) ==
	sudo umount ${devname}${PSUF}1

	echo "== Done... =="
}


populate_sd_card_rootfs_and_fat() {
	local devname="$1"
	local PSUF
	local TMP="/tmp"

	local mount_dir1="${TMP}/mount_work1/"
	local mount_dir2="${TMP}/mount_work2/"

	mkdir -p ${mount_dir1}
	mkdir -p ${mount_dir2}

	if [[ $devname == /dev/mmcblk* ]] ; then
		PSUF=p
	fi

	echo == Unmounting partitions first ==
	sudo umount ${devname}${PSUF}1 &> /dev/null || true
	sudo umount ${devname}${PSUF}2 &> /dev/null || true

	# Populate rootfs
	echo "== Populating rootfs partition '${devname}${PSUF}2' =="
	sudo mount ${devname}${PSUF}2 ${mount_dir2}
	untar_roofs "${mount_dir2}"

	echo "== Populating boot partition '${devname}${PSUF}1' with files from '${mount_dir2}/boot' =="
	# Populate FAT
	sudo mount ${devname}${PSUF}1 ${mount_dir1}
	copy_boot_files "${mount_dir2}/boot" "${mount_dir1}"

	echo "== Syncing... =="

	sudo sync

	echo == Unmounting partitions \(almost done\) ==
	sudo umount ${devname}${PSUF}2
	sudo umount ${devname}${PSUF}1

	echo "== Done... =="
}

echo "=================================================================="
echo "| WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! |"
echo "|                                                                |"
echo "| This will erase all files on partitions of '$1'"
echo "| Press Enter to continue.........                               |"
echo "|                                                                |"
echo "| WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! |"
echo "=================================================================="
read ans

DEVICE="$1"
if [ "$DEVICE" = "vision-ai-rzv2l" ] ; then
	populate_sd_card_rootfs "$2"
else
	echo "Unsupported device $DEVICE"
	exit 1
fi

DEVICE="$1"
if [ "$DEVICE" = "smarc-rzg2l" ] ; then
        populate_sd_card_rootfs_and_fat "$2"
elif [ "$DEVICE" = "smarc-rzv2l" ] ; then
        populate_sd_card_rootfs_and_fat "$2"
else
        echo "Unsupported device $DEVICE"
        exit 1
fi
