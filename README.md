# Hot Plug Wifi Adapters for OpenIPC Radxa GroundStation (PixelPilot_rk)

## Description
Configure the `autoload-wfb-nics.sh` script in your Radxa GroundStation to enable the support for hot plugging Wifi Adapters.

## Features
- Hot plug wfb-ng supported wireless NICs
- Wifibroadcast will automatically be restarted with the currently plugged in adapters
- No system reboot required
- No configuration changes for wfb-ng required


## Installation
1. Copy the script `autoload-wfb-nics.sh` to `/home/radxa/scripts` folder
2. The script contains list of MAC prefixes of commonly supported wifi adapters. Please add your own if it is not already added
3. Provide the executable permission for the script with the command `sudo chmod +x autoload-wfb-nics.sh`
4. Update the content of `98-custom-wifi.rules and 99-custom-wifi.rules`  located at `/etc/udev/rules.d`
5. Reboot the system

## Usage
- Once installed, you can plug or remove wifi adapters into the ground station and it will automatically detect and restart wifibroadcast with the correct adapters
