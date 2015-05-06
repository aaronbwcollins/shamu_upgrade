#!/bin/bash

STEP=0

ERROR_HANDLER ()
{
	echo "Script aborted while on $CURRENT_STEP."
	echo
	exit 1
}

PREP ()
{
	CURRENT_STEP="Prep"
	if ! [ -d /tmp/shamu-lmy47i/ ];
		then
		echo "Getting Base Image"
		echo
		echo "This may take some time"
		wget https://dl.google.com/dl/android/aosp/shamu-lmy47i-factory-c8afc588.tgz
		cd /tmp/
		tar -zxvf shamu-lmy47i-factory-c8afc588.tgz
		unzip shamu-lmy47i/image-shamu-lmy47i.zip
		STEP=1 
	fi
}

SDK_CHECK ()
{
	CURENT_STEP="SDK CHECK"
	if ! [ -d ~/Library/Android/sdk/platform-tools/ ]
		echo "Installing Android Studio"
		cd /tmp
		wget https://dl.google.com/dl/android/studio/install/1.2.0.12/android-studio-ide-141.1890965-mac.dmg
		open android-studio-ide-141.1890965-mac.dmg
			
