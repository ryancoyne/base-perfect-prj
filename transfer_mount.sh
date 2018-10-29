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
EMAIL_SUBJECT="Transfer Mount Message"
EMAIL_SUBJECT_ERROR="ERROR: Transfer Mount Message"
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
    echo "The mount /transfer is already mounted"
  else
    sudo -s mount /transfer > /dev/null

    if sudo -s mount | grep /transfer > /dev/null; then
      echo "The mount /transfer was mounted"
    else
    	echo "/transfer was NOT mounted.  Can not continue"
      MESSAGE="/transfer was NOT mounted.  Can not continue"
      echo "${MESSAGE}" | mailx -s "${EMAIL_SUBJECT_ERROR}" -a "${EMAIL_FROM}"  "${EMAIL_TO}"
	    exit -1;
    fi
fi

# make sure directories exist
if [ ! -d "/transfer/tmp" ]; then
    sudo -s mkdir /transfer/tmp
fi

if [ ! -d "/transfer/sent" ]; then
    sudo -s mkdir /transfer/sent
fi

if [ ! -d "/transfer/tosend" ]; then
    sudo -s mkdir /transfer/tosend
fi

# if we made it this far the mount was successful.
