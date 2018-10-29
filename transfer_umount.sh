#!/bin/bash

###########################################################################################################
# transfer_mount.sh
# Created by: Mike Silvers
# Date: 10/30/2018
# Description:
# This script will mount the directory for file transfer.
##
# Modification log:
# -----------------
#    Date            Name        Description
# ==========  ================== ==========================================================================
#
#
#
#
###########################################################################################################

EMAIL_TO="engineering@buckettechnologies.com,mike.silvers@buckettechnologies.com"
EMAIL_SUBJECT="Transfer UMount Message"
EMAIL_SUBJECT_ERROR="ERROR: Transfer UMount Message"
EMAIL_FROM="From: transfer@bucketthechange.com (Transfer Server)"

# run as root
# if [[ $EUID -ne 0 ]]; then
#    echo "This script must be run as root"
#    MESSAGE="The script was not run by a root user.  The user `whoami` was attempting to run the script."
#    echo "${MESSAGE}" | mailx -s "${EMAIL_SUBJECT_ERROR}" -a "${EMAIL_FROM}"  "${EMAIL_TO}"
#    exit 1;
# fi

## Check to make sure the file mount is mounted
if sudo -s mount | grep /transfer > /dev/null; then
    sudo -s umount /transfer > /dev/null
    echo "The mount /transfer was unmounted"
fi

# if we made it this far the umount was successful.
