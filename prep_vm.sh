#!/bin/bash

# T&M Hansson IT AB © - 2020, https://www.hanssonit.se/

####### MASTER #######

# shellcheck disable=2034,2059
true
# shellcheck source=lib.sh
. <(curl -sL https://raw.githubusercontent.com/nextcloud/vm/master/lib.sh)

# Check for errors + debug code and abort if something isn't right
# 1 = ON
# 0 = OFF
DEBUG=0
debug_mode

# Create scripts folder
mkdir -p "$SCRIPTS"

# Get needed scripts for first bootup
download_script GITHUB_REPO lib
download_script GITHUB_REPO nextcloud_install_production
download_script STATIC history
download_script STATIC static_ip

# Make $SCRIPTS excutable
chmod +x -R "$SCRIPTS"
chown root:root -R "$SCRIPTS"

# Check if dpkg or apt is running
is_process_running apt
is_process_running dpkg

# Upgrade
apt update -q4 & spinner_loading
apt dist-upgrade -y

# Remove LXD (always shows up as failed during boot)
apt-get purge lxd -y

# Put IP adress in /etc/issue (shown before the login)
if [ -f /etc/issue ]
then
    echo "\4" >> /etc/issue
    echo "USER: ncadmin" >> /etc/issue
    echo "PASS: nextcloud" >> /etc/issue
fi

####### OFFICIAL (custom scripts) #######

# shellcheck disable=2034,2059
true
# shellcheck source=lib.sh
. <(curl -sL https://raw.githubusercontent.com/nextcloud/vm/official/lib.sh)

# Get needed scripts for first bootup
download_script STATIC instruction
curl_to_dir https://raw.githubusercontent.com/nextcloud/vm/official/static welcome.sh "$HOME"

# Prepare first bootup
check_command run_script STATIC change-ncadmin-profile
check_command run_script STATIC change-root-profile
