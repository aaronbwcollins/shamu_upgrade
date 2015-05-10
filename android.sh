#!/bin/bash
###################################
###################################
###################################
#
#
# Nexus 6 Rooted upgrade script
#
# v 1.0
#
# By Aaron B.W. Collins
#
#
###################################
###################################
###################################

ERROR_HANDLER ()
{
	echo "Script aborted while on $CURRENT_STEP."
	echo
	exit 1
## Need to add || error statements.
}

PAUSE ()
{
	read -p "$*"
}

PREP ()
{
	CURRENT_STEP="Prep"
	STEP=0
	echo "Starting Prep."
	if ! [ -d /tmp/nexus6/shamu-lmy47i/ ];
		then
		echo
		echo "Getting Base Image"
		echo
		echo "This may take some time"
		echo
		cd /tmp
		mktemp -d "nexus6"
		cd /tmp/nexus6
		curl -O  https://dl.google.com/dl/android/aosp/shamu-lmy47i-factory-c8afc588.tgz
		tar -zxvf shamu-lmy47i-factory-c8afc588.tgz
		unzip shamu-lmy47i/image-shamu-lmy47i.zip
		STEP=1 
	fi
}

SDK_CHECK ()
{
## ZIP up adb and fastboot and deliver those instead of installing android studio.
## Use IF statement to check for SDK before checking /usr/bin
## Install to usr/bin regarless

	CURENT_STEP="SDK CHECK"
	if ! [ -f ~/Library/Android/sdk/platform-tools/ ]
		then
		if ! [ -e /usr/bin/adb ]
			then
			sudo unzip ~/Downloads/tools.zip /usr/bin
		else
			echo "ADB and Fastboot look good."
		fi		
	else
		cp ~/Library/Android/sdk/platform-tools/adb /usr/bin
		cp ~/Library/Android/sdk/platform-tools/fastboot /usr/bin
			
	fi
	STEP=2
}

ENTER_BOOTLOADER ()
{
## See about creating check for whether the device is attached
	CURRENT_STEP="Entering Bootloader"
	echo "Make sure phone is plugged in"
	echo "MAKE SURE OEM UNLOCKING is ON!"
	PAUSE "Press any key to continue"
	#if [ adb devices | grep 
	adb reboot-bootloader # Enter Bootloader
	echo "Please" ## Enter instructions for entering adb
	PAUSE "Press any key to continue"
	STEP=3
}

BOOTLOADER_RADIO ()
{
	CURRENT_STEP="Flashing Bootloader & Radio img."
	fastboot flash bootloader /tmp/nexus6/shamu-lmy47i/bootloader-shamu-moto-apq8084-71.08.img # Flash Bootloader.img
	fastboot flash radio /tmp/nexus6/shamu-lmy47i/radio-shamu-d4.0-9625-02.95.img # Flash Radio.img
	STEP=4
}

BOOTLOADER_REBOOT ()
{
	CURRENT_STEP="Rebooting Bootloader"
	fastboot reboot-bootloader # Reboot Bootloader
	STEP=5
}

BOOTLOADER_RECOVERY_BOOT_SYSTEM ()
{
	CURRENT_STEP="Flashing Recovery, Boot, and System img."
	fastboot flash recovery /tmp/nexus6/recovery.img # Flash Recovery.img
	fastboot flash boot /tmp/nexus6/boot.img # Flash Boot.img
	fastboot flash system /tmp/nexus6/system.img # Flash System.img
	STEP=6
}

REBOOT ()
{
	CURRENT_STEP="Rebooting"
	fastboot reboot # Reboot Device
	echo "Rebooting your device"
}

BOOTLOADER_ROOT ()
{
	CURRENT_STEP="Rooting Device"
	echo
	echo "Please wait till update is finished before proceeding"
	echo
	echo
	PAUSE "Please press any key to proceed with rooting."
	cd /tmp/nexus6
	curl -O https://download.chainfire.eu/628/CF-Root1/CF-Auto-Root-shamu-shamu-nexus6.zip?retrieve_file=1
	unzip CF-Auto-Root-shamu-shamu-nexus6.zip\?retrieve_file\=1	
	flashboot bootloader
	flashboot boot /tmp/image/CF-Auto-Root-shamu-shamu-nexus6.img
}

CLEANUP ()
{
	sudo rm -rf /tmp/nexus6
}
#####			      #####
## Call Functions in Run Fuction ##
#####			      #####
RUN ()
{
PREP
SDK_CHECK
}

## Make sure $1 exists
## If it dosen't, run the RUN function
## If it does, run that function
## Assuming it does:
if [ $# -eq 0 ]
	then
	RUN
	else
	command=$1
	eval $1
fi
