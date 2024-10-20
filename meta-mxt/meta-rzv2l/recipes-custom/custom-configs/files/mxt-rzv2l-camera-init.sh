#!/bin/sh

rm -f /tmp/app-usbcam-http-config

CSI2_DEV="csi-10830400.csi2"
CRU_OUTPUT="cru-ip-10830000.video"

v4l2_set_sensor_control() {
	sensor_name="$1"
	control="$2"

	for subdev in /dev/v4l-subdev* ; do
		if media-ctl --print-dot | grep "$sensor_name" | grep -q "$subdev" ; then
			v4l2-ctl -d $subdev $control
			return 0
		fi
	done
}

if media-ctl -d /dev/media0 -V "'imx135 1-0010':0 [fmt:SRGGB10_1X10/1280x720 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx135 1-0010':0"
	media-ctl -d /dev/media0 -V "'${CSI2_DEV}':1 [fmt:SRGGB10_1X10/1280x720 field:none]"
	media-ctl -d /dev/media0 -l "'${CSI2_DEV}':1 -> '${CRU_OUTPUT}':0 [1]"

	echo 'NATIVE_CAMERA_IMAGE_WIDTH=1280' > /tmp/app-usbcam-http-config
	echo 'NATIVE_CAMERA_IMAGE_HEIGHT=720' >> /tmp/app-usbcam-http-config

	v4l2_set_sensor_control "imx135 1-0010" --set-ctrl=digital_gain=4
	v4l2_set_sensor_control "imx135 1-0010" --set-ctrl=analogue_gain=140
	v4l2_set_sensor_control "imx135 1-0010" --set-ctrl=exposure=3000

	exit 0
fi

if media-ctl -d /dev/media0 -V "'tevs 1-0048':0 [fmt:UYVY8_2X8/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'tevs 1-0048':0"
	media-ctl -d /dev/media0 -V "'${CSI2_DEV}':1 [fmt:UYVY8_2X8/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'${CSI2_DEV}':1 -> '${CRU_OUTPUT}':0 [1]"

	exit 0
fi

# FIXME: we start with 1920x1080 (as it's in the datasheet), but we try to go for 640x480 (if we can)
if media-ctl -d /dev/media0 -V "'imx415 1-001a':0 [fmt:SGBRG10_1X10/1920x1080 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx415 1-001a':0"
	media-ctl -d /dev/media0 -V "'${CSI2_DEV}':1 [fmt:SGBRG10_1X10/1920x1080 field:none]"
	media-ctl -d /dev/media0 -l "'${CSI2_DEV}':1 -> '${CRU_OUTPUT}':0 [1]"

	echo "NATIVE_CAMERA_IMAGE_WIDTH=1920" > /tmp/app-usbcam-http-config
	echo "NATIVE_CAMERA_IMAGE_HEIGHT=1080" >> /tmp/app-usbcam-http-config

	exit 0
fi

if media-ctl -d /dev/media0 -V "'ov5647 1-0036':0 [fmt:SBGGR10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'ov5647 1-0036':0"
	media-ctl -d /dev/media0 -V "'${CSI2_DEV}':1 [fmt:SBGGR10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'${CSI2_DEV}':1 -> '${CRU_OUTPUT}':0 [1]"

	v4l2_set_sensor_control "ov5647 1-0036" --set-ctrl=gain_automatic=1
	v4l2_set_sensor_control "ov5647 1-0036" --set-ctrl=white_balance_automatic=1
	v4l2_set_sensor_control "ov5647 1-0036" --set-ctrl=auto_exposure=0  # 0 = auto-exposure, 1 = manul

	exit 0
fi

if media-ctl -d /dev/media0 -V "'imx219 1-0010':0 [fmt:SRGGB10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx219 1-0010':0"
	media-ctl -d /dev/media0 -V "'${CSI2_DEV}':1 [fmt:SRGGB10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'${CSI2_DEV}':1 -> '${CRU_OUTPUT}':0 [1]"

	# IMX 219 does not have any controls for automatic gain or auto-exposure, or auto-white-balance
	# We just get these 2 (digital & analogue) gain controls; we'll set some reasonable defaults here
	# root@smarc-rzv2l:~# v4l2-ctl --all | grep gain
	#          analogue_gain 0x009e0903 (int)    : min=0 max=232 step=1 default=0 value=128
	#           digital_gain 0x009f0905 (int)    : min=256 max=4095 step=1 default=256 value=2047

	v4l2_set_sensor_control "imx219 1-0010" --set-ctrl=digital_gain=2000
	v4l2_set_sensor_control "imx219 1-0010" --set-ctrl=analogue_gain=200

	exit 0
fi

# FIXME: needs testing
if media-ctl -d /dev/media0 -V "'imx296 1-001a':0 [fmt:SRGGB10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx296 1-001a':0"
	media-ctl -d /dev/media0 -V "'${CSI2_DEV}':1 [fmt:SRGGB10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'${CSI2_DEV}':1 -> '${CRU_OUTPUT}':0 [1]"

	exit 0
fi

if media-ctl -d /dev/media0 -V "'imx708_noir':0 [fmt:SRGGB10_1X10/1536x864 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx708_noir':0"

	echo 'NATIVE_CAMERA_IMAGE_WIDTH=1536' > /tmp/app-usbcam-http-config
	echo 'NATIVE_CAMERA_IMAGE_HEIGHT=864' >> /tmp/app-usbcam-http-config

	media-ctl -d /dev/media0 -V "'${CSI2_DEV}':1 [fmt:SSRGGB10_1X10/1536x864 field:none]"
	media-ctl -d /dev/media0 -l "'${CSI2_DEV}':1 -> '${CRU_OUTPUT}':0 [1]"

	v4l2_set_sensor_control "imx708_noir" --set-ctrl=digital_gain=2000
	v4l2_set_sensor_control "imx708_noir" --set-ctrl=analogue_gain=700

	exit 0
fi

if media-ctl -d /dev/media0 -V "'arducam-pivariety 1-000c':0 [fmt:SRGGB10_1X10/1920x1080 field:none]" &> /dev/null ; then
	echo "Using camera is 'arducam-pivariety 1-000c':0"

	echo 'NATIVE_CAMERA_IMAGE_WIDTH=1920' > /tmp/app-usbcam-http-config
	echo 'NATIVE_CAMERA_IMAGE_HEIGHT=1080' >> /tmp/app-usbcam-http-config

	media-ctl -d /dev/media0 -V "'${CSI2_DEV}':1 [fmt:SRGGB10_1X10/1920x1080 field:none]"
	media-ctl -d /dev/media0 -l "'${CSI2_DEV}':1 -> '${CRU_OUTPUT}':0 [1]"

	v4l2_set_sensor_control "arducam-pivariety 1-000c" --set-ctrl=analogue_gain=10000

	exit 0
fi

echo "No supported camera found"
