#!/bin/bash -e

#
# Usage ./format_sdcard.sh <device-name> <sd-card-device>
#

contains() {
	[[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]] && return 0 || return 1
}

SUPPORTED_DEVICES="smarc-rzg2l smarc-rzv2l vision-ai-rzv2l"

usage_check() {
	if [ -z "$1" ] ; then
		echo "No device-name specified"
		echo "Usage: $0 <device-name> <sd-card-device>"
		exit 1
	fi
	if ! contains "$SUPPORTED_DEVICES" "$1" ; then
		echo "Device '$1' unknown; Supported list is '$SUPPORTED_DEVICES'"
		echo "Usage: $0 <device-name> <sd-card-device>"
		exit 1
	fi
	if [ -z "$2" ] ; then
		echo "No SD card device provided"
		echo "Usage: $0 <device-name> <sd-card-device>"
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
}

usage_check "$1" "$2"

# Tune these as needed
SZ_SUFFIX=G                 # G=1024*3 ; GB=1000*3 (choose your favorite)
FAT_SIZE=256M
EXT_TYPE=ext4
FAT_PART_LABEL=RZ_FAT
ROOTFS_PART_LABEL=RZ_ext

format_partition() {
	DEV="$1"
	TYPE="$2"
	PART_LABEL="$3"

	sudo dd if=/dev/zero of=${DEV} bs=1M count=1

	# format as ext3/ext4
	if [ "$TYPE" = "vfat" ] ; then
		sudo mkfs.vfat -F 32 -n $PART_LABEL $DEV
	else
		sudo mkfs.${TYPE} -O ^metadata_csum,^64bit,^orphan_file  -L $PART_LABEL $DEV
	fi
}

format_sd_card_single_rootfs() {
	local devname="$1"
	local PSUF

	for dev in ${devname}* ; do
		sudo umount $dev &> /dev/null || true
	done

	echo "== Destroying Master Boot Record =="
	sleep 1
	sudo dd if=/dev/zero of=${devname} bs=1M count=1

	echo "== Writing new partition layout =="
	sleep 1
	# Create 1 rootfs partition (with the entire disk)
	echo -e "n\np\n1\n\n\n" \
		"t\n83\n" \
		"p\nw\n" | sudo fdisk -u $devname

	sudo sync

	if [[ $devname == /dev/mmcblk* ]] ; then
		PSUF=p
	fi

	echo "== Formatting partitions =="
	sleep 1
	format_partition ${devname}${PSUF}1 ${EXT_TYPE} $ROOTFS_PART_LABEL

	sudo sync
}

format_sd_card_fat_and_rootfs() {
	local devname="$1"
	local PSUF

	for dev in ${devname}* ; do
		sudo umount $dev &> /dev/null || true
	done

	echo "== Destroying Master Boot Record =="
	sleep 1
	sudo dd if=/dev/zero of=${devname} bs=1M count=1

	echo "== Writing new partition layout =="
	sleep 1
	# Create 1 FAT partition and 1 rootfs partition (with remainder of disk)
	echo -e "n\np\n1\n\n+${FAT_SIZE}\n" \
		"n\np\n2\n\n\n" \
		"t\n1\n6\n" \
		"p\nw\n" | sudo fdisk -u $devname

	sudo sync

	if [[ $devname == /dev/mmcblk* ]] ; then
		PSUF=p
	fi

	echo "== Formatting partitions =="
	sleep 1
	format_partition ${devname}${PSUF}1 vfat $FAT_PART_LABEL
	format_partition ${devname}${PSUF}2 ${EXT_TYPE} $ROOTFS_PART_LABEL

	sudo sync
}

echo "=================================================================="
echo "| WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! |"
echo "|                                                                |"
echo "| This will destroy all data on '$1'"
echo "| Press Enter to continue.........                               |"
echo "|                                                                |"
echo "| WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! |"
echo "=================================================================="
read ans

DEVICE="$1"
if [ "$DEVICE" = "smarc-rzg2l" ] ; then
	format_sd_card_fat_and_rootfs "$2"
elif [ "$DEVICE" = "smarc-rzv2l" ] ; then
	format_sd_card_fat_and_rootfs "$2"
elif [ "$DEVICE" = "vision-ai-rzv2l" ] ; then
	format_sd_card_single_rootfs "$2"
else
	echo "Unsupported device $DEVICE"
	exit 1
fi
