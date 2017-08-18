#!/bin/sh

# USER_DIR=${USER_DIR:="/usbdrive"}
# PATCH_DIR=${PATCH_DIR:="/usbdrive/Patches"}
export FW_DIR=${FW_DIR:="/root"}
SCRIPTS_DIR=$FW_DIR/scripts


# quit Pd 
$SCRIPTS_DIR/killpd.sh
# then mother
# give a chance to shut itself off
oscsend localhost 4001 /quitmother i 1
sleep .1

# kill SIGTERM 
killall mother
sleep .1

# and kill SIGKILL 
killall -s 9 mother

