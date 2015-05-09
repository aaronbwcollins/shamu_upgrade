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
}

PAUSE ()
{
	read -p "$*"
}

PREP ()
{
	CURRENT_STEP="Prep"
	STEP=0
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
	CURENT_STEP="SDK CHECK"
	if ! [ -f ~/Library/Android/sdk/platform-tools/ ]
		then
		cd /tmp/nexus6
		curl -O https://dl.google.com/dl/android/studio/install/1.2.0.12/android-studio-ide-141.1890965-mac.dmg		
		open /tmp/nexus6/android-studio-ide-141.1890965-mac.dmg
		echo "Move Android Studio to Application Folder"
		PAUSE "Press any key to continue"
		open /Applications/Android\ Studio.app/
		sleep 10
		PAUSE "Finsh Install then press a key"
		echo "Copying adb and fastboot to /usr/binl"		
		cp ~/Library/Android/sdk/platform-tools/adb /usr/bin
		cp ~/Library/Android/sdk/platform-tools/fastboot /usr/bin	
	else
		echo "ADB and Fastboot look good."			
	fi
	STEP=2
}

ENTER_BOOTLOADER ()
{
	CURRENT_STEP="Entering Bootloader"
	echo "Make sure phone is plugged in"
	echo "MAKE SURE OEM UNLOCKING is ON!"
	PAUSE "Press any key to continue"
	adb devices | grep online
	adb reboot-bootloader
	STEP=3
}

BOOTLOADER_RADIO ()
{
	CURRENT_STEP="Flashing Bootloader & Radio img."
	fastboot flash bootloader /tmp/nexus6/shamu-lmy47i/ #bootloader.img
	fastboot flash radio /tmp/nexus6/shamu-lmy47i/ #radio.img
	STEP=4
}

BOOTLOADER_REBOOT ()
{
	CURRENT_STEP="Rebooting Bootloader"
	fastboot reboot-bootloader
	STEP=5
}

BOOTLOADER_RECOVERY_BOOT_SYSTEM ()
{
	CURRENT_STEP="Flashing Recovery, Boot, and System img."
	fastboot flash recovery /tmp/shamu-lmy47i/ #recovery.img
	fastboot flash boot /tmp/shamu-lmy47i/ #boot.img
	fastboot flash system /tmp/shamu-lmy47i/ #system.img
	STEP=6
}

REBOOT ()
{
	CURRENT_STEP="Rebooting"
	fastboot reboot
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
#####
##Call Functions in Run Fuction
#####
RUN ()
{
PREP
SDK_CHECK
}

## Make sure $1 exists
## Assuming it does:
if [ $# -eq 0 ]
	then
	RUN
	else
	command=$1
	eval $1
fi
