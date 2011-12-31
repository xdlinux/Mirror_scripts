#!/bin/bash
#
# The script to sync a local mirror of the Arch Linux repositories and ISOs
#
# Copyright (C) 2007 Woody Gilk <woody@archlinux.org>
# Modifications by Dale Blount <dale@archlinux.org>
# and Roman Kyrylych <roman@archlinux.org>
# Licensed under the GNU GPL (version 2)

# Filesystem locations for the sync operations
source `dirname $0`/functions.d/functions

SYNC_LOGS="$SYNC_HOME/logs/gentoo"
SYNC_FILES="/srv/ftp/gentoo"
SYNC_LOCK="$SYNC_HOME/gentoo.lck"
#SYNC_SERVER="rsync://ftp.tw.gentoo.org/gentoo/"
#SYNC_SERVER="rsync://oss.ustc.edu.cn/pub/gentoo/"
#SYNC_SERVER="rsync://mirrors6.ustc.edu.cn/gentoo/"
SYNC_SERVER="rsync://mirrors.xmu6.edu.cn/gentoo/"
LOG_FILE="gentoo_$(date +%Y%m%d-%H).log"

STAT_FILE="$SYNC_HOME/status/gentoo"

set_stat $STAT_FILE "-1"
# Do not edit the following lines, they protect the sync from running more than
# one instance at a time
if [ ! -d $SYNC_HOME ]; then
  echo "$SYNC_HOME does not exist, please create it, then run this script again."
  exit 1
fi

[ -f $SYNC_LOCK ] && exit 1
touch "$SYNC_LOCK"
# End of non-editable lines

# Create the log file and insert a timestamp
touch "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Starting sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
#starting rsync


rsync -6 -av --delete-after --exclude *.~tmp~*  $SYNC_SERVER $SYNC_FILES >> $SYNC_LOGS/$LOG_FILE

set_stat $STAT_FILE $?

date --rfc-3339=seconds > "$SYNC_FILES/lastsync"
# Insert another timestamp and close the log file
echo ">> ---" >> "$SYNC_LOGS/$LOG_FILE"
echo ">> Finished sync on $(date --rfc-3339=seconds)" >> "$SYNC_LOGS/$LOG_FILE"
echo "=============================================" >> "$SYNC_LOGS/$LOG_FILE"
echo "" >> "$SYNC_LOGS/$LOG_FILE"

# Remove the lock file and exit
rm -f "$SYNC_LOCK"
exit 0
