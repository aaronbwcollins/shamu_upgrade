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
	echo
	echo "Starting Prep."
	if ! [ -d /tmp/nexus6/shamu-lmy47i/ ];
		then
		echo
		echo "Getting Base Image."
		echo
		echo "This may take some time..."
		echo
		cd /tmp
		mktemp -d "nexus6" || ERROR_HANDLER
		cd /tmp/nexus6
		curl -O  https://dl.google.com/dl/android/aosp/shamu-lmy47i-factory-c8afc588.tgz || ERROR_HANDLER
		tar -zxvf shamu-lmy47i-factory-c8afc588.tgz || ERROR_HANDLER
		unzip shamu-lmy47i/image-shamu-lmy47i.zip || ERROR_HANDLER
	fi
}

SDK_CHECK ()
{
	CURENT_STEP="SDK CHECK"
	if ! [ -f ~/Library/Android/sdk/platform-tools/ ]
		then
		if ! [ -e /usr/bin/adb ]
			then
			unzip ~/Downloads/tools.zip -d /tmp/nexus6 || ERROR_HANDLER
			sudo cp /tmp/nexus6/tools/adb /usr/local/bin/ || ERROR_HANDLER
			sudo cp /tmp/nexus6/tools/fastboot /usr/local/bin/ || ERROR_HANDLER
		else
			echo "ADB and Fastboot look good."
		fi		
	else
		cp ~/Library/Android/sdk/platform-tools/adb /usr/local/bin || ERROR_HANDLER
		cp ~/Library/Android/sdk/platform-tools/fastboot /usr/local/bin || ERROR_HANDLER
	fi
}

ENTER_BOOTLOADER ()
{
## See about creating check for whether the device is attached
	CURRENT_STEP="Entering Bootloader"
	echo
	echo "Make sure phone is plugged in"
	echo "MAKE SURE OEM UNLOCKING is ON!"
	PAUSE "Press any key to continue..."
	#if [ adb devices | grep 
	adb reboot-bootloader || ERROR_HANDLER # Enter Bootloader 
	#echo "Please" ## Enter instructions for entering adb
	echo
	echo "Entering Bootloader"
	PAUSE "Press any key to continue..."
}

BOOTLOADER_RADIO ()
{
	CURRENT_STEP="Flashing Bootloader & Radio img."
	fastboot flash bootloader /tmp/nexus6/shamu-lmy47i/bootloader-shamu-moto-apq8084-71.08.img || ERROR_HANDLER # Flash Bootloader.img
	fastboot flash radio /tmp/nexus6/shamu-lmy47i/radio-shamu-d4.0-9625-02.95.img || ERROR_HANDLER # Flash Radio.img
}

BOOTLOADER_REBOOT ()
{
	CURRENT_STEP="Rebooting Bootloader"
	fastboot reboot-bootloader || ERROR_HANDLER # Reboot Bootloader
}

BOOTLOADER_RECOVERY_BOOT_SYSTEM ()
{
	CURRENT_STEP="Flashing Recovery, Boot, and System img."
	fastboot flash recovery /tmp/nexus6/recovery.img || ERROR_HANDLER # Flash Recovery.img
	fastboot flash boot /tmp/nexus6/boot.img || ERROR_HANDLER # Flash Boot.img
	fastboot flash system /tmp/nexus6/system.img || ERROR_HANDLER # Flash System.img
}

REBOOT ()
{
	CURRENT_STEP="Rebooting"
	fastboot reboot || ERROR_HANDLER # Reboot Device
	echo "Rebooting your device."
}

BOOTLOADER_ROOT ()
{
	CURRENT_STEP="Rooting Device"
	echo
	echo "Please wait till update is finished before proceeding."
	echo
	echo
	PAUSE "Please press any key to proceed with rooting."	
	adb reboot-bootloader || ERROR_HANDLER
	sleep 5
	fastboot boot /tmp/nexus6/tools/CF-Auto-Root-shamu-shamu-nexus6.img || ERROR_HANDLER
}

CLEANUP ()
{
	sudo rm -rf /tmp/nexus6 || echo "Couldn't Delete /tmp/nexus6 "
	echo
	echo "All done!"
	echo
	echo "Your phone will take a while to boot."
	echo "This is normal."
	echo "Be Patient!"
	echo
}

help ()
{
	echo
	echo "Commands Availabe:"
	echo
	echo "PREP, SDK_CHECK, ENTER_BOOTLOADER, BOOTLOADER_RADIO,"
	echo "BOOTLOADER_REBOOT, BOOTLOADER_RECOVERY_BOOT_SYSTEM, REBOOT"
	echo "BOOTLOADER_ROOT CLEANUP"
	echo
	echo "Type ./android.sh to run the full script"
	echo
	echo
	echo "Type ./android.sh COMMAND to specify a function" 
	echo 
	echo
	echo
}
#####
## Call Functions in Run Fuction ##
#####
RUN ()
{
	PREP
	SDK_CHECK
	ENTER_BOOTLOADER
	echo "Flash Device?"
	PAUSE "Press any key to continue..."
	BOOTLOADER_RADIO
	BOOTLOADER_REBOOT
	sleep 5
	BOOTLOADER_RECOVERY_BOOT_SYSTEM
	REBOOT
	read -p "Reboot Now?" yn
		case $yn in
			[Yy]* ) BOOTLOADER_ROOT
				sleep 5
				REBOOT
				;;
			 * ) break
				;;
		esac
	CLEANUP
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