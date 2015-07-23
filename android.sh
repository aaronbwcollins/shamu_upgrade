#!/bin/bash
###################################
###################################
###################################
#
#
# Nexus 6 Rooted upgrade script
#
# v 2.0
#
# By Aaron B.W. Collins
#
#
###################################
###################################
###################################

##TODO add readme disclamer about multipe devicesv

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
	VARIABLES
	if ! [ -d /tmp/nexus6/ ];
		then
		echo
		echo "Getting Base Image."
		echo
		echo "This may take some time..."
		echo
		cd /tmp
		mktemp -d "nexus6" || ERROR_HANDLER
		cd /tmp/nexus6
		curl -O  $image_link || ERROR_HANDLER
		tar -zxvf $tar_file || ERROR_HANDLER
		unzip $zip_file || ERROR_HANDLER
		unzip /$gitdir/tools.zip -d /tmp/nexus6 || ERROR_HANDLER
	fi
}

VARIABLES ()
{
#!/bin/bash
# Bash Menu Script Example

gitdir=$PWD

PS3='Please enter your choice: '
options=("T-Mobile" "Project Fi" "Other Carriers" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "T-Mobile")
            echo "You've selected T-Mobile"
            #T-Mobile
			image_link="https://dl.google.com/dl/android/aosp/shamu-lyz28e-factory-b542b88a.tgz"
			tar_file="shamu-lyz28e-factory-b542b88a.tgz"
			zip_file="shamu-lyz28e/image-shamu-lyz28e.zip"
			bootloader="shamu-lyz28e/bootloader-shamu-moto-apq8084-71.10.img"
			radio="shamu-lyz28e/radio-shamu-d4.0-9625-02.101.img"
			break
            ;;
        "Project Fi")
            echo "You've selected Project Fi"
            #Project Fi
			image_link="https://dl.google.com/dl/android/aosp/shamu-lvy48c-factory-4b92ce24.tgz"
			tar_file="shamu-lvy48c-factory-4b92ce24.tgz"
			zip_file="shamu-lvy48c/image-shamu-lvy48c.zip"
			bootloader="shamu-lvy48c/bootloader-shamu-moto-apq8084-71.10.img"
			radio="radio-shamu-d4.0-9625-02.102+fsg-9625-02.78.05.img"
			break
            ;;
        "Other Carriers")
            echo "You've selected Other Carriers"
            #OTHER CARRIERS
			image_link="https://dl.google.com/dl/android/aosp/shamu-lmy47z-factory-33951732.tgz"
			tar_file="shamu-lmy47z-factory-33951732.tgz"
			zip_file="shamu-lmy47z/image-shamu-lmy47z.zip"
			bootloader="shamu-lmy47z/bootloader-shamu-moto-apq8084-71.10.img"
			radio="shamu-lmy47z/radio-shamu-d4.0-9625-02.101.img"
			break
            ;;
        "Quit")	
            exit 1
            ;;
        *) echo invalid option;;
    esac
done

}

SDK_CHECK ()
{
	CURENT_STEP="SDK CHECK"
	if ! [ -f ~/Library/Android/sdk/platform-tools/ ]
		then
		if ! [ -e /usr/local/bin/adb ]; then
			sudo cp /tmp/nexus6/tools/adb /usr/local/bin/ || ERROR_HANDLER
			sudo cp /tmp/nexus6/tools/fastboot /usr/local/bin/ || ERROR_HANDLER
		else
			echo "ADB and Fastboot look good."
		fi		
	else
		ln -s ~/Library/Android/sdk/platform-tools/adb /usr/local/bin/adb || ERROR_HANDLER
		ln -s ~/Library/Android/sdk/platform-tools/fastboot /usr/local/bin/fastboot || ERROR_HANDLER
	fi
}

BOOT_VERIFY ()
{
	serial=$(adb devices | cut -c1-10 | sed '1d')
	echo "Waiting for Phone"
	while [ -z $serial ]
	do
	sleep 1 > /dev/null
	serial=$(adb devices | cut -c1-10 | sed '1d')
	done
}

ENTER_BOOTLOADER ()
{
## See about creating check for whether the device is attached
	CURRENT_STEP="Entering Bootloader"
	echo
	echo "MAKE SURE OEM UNLOCKING is ON!"
	PAUSE "Press any key to continue..."
	echo "Make sure phone is plugged in"
	BOOT_VERIFY
	adb reboot-bootloader || ERROR_HANDLER # Enter Bootloader 
	echo
	echo "Entering Bootloader"
	sleep 7
}

BOOTLOADER_RADIO ()
{
	CURRENT_STEP="Flashing Bootloader & Radio img."
	fastboot flash bootloader /tmp/nexus6/$bootloader || ERROR_HANDLER # Flash Bootloader.img
	fastboot flash radio /tmp/nexus6/$radio || ERROR_HANDLER # Flash Radio.img
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
	BOOT_VERIFY	
	adb reboot-bootloader || ERROR_HANDLER
	sleep 5
	fastboot boot tmp/nexus6/tools/CF-Auto-Root-shamu-shamu-nexus6.img || ERROR_HANDLER
	BOOT_VERIFY
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
	echo "Phone Now Rebooting"
	echo
	echo "This May Take Awhile"
	echo
	PAUSE "Press any key once phone is FULLY rebooted"
	read -p "Root Device?" yn
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