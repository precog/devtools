#!/usr/bin/env bash


printf "Starting slamdata-vm-provisioner.sh script.\n\n"

# ======== Component Selection ========
INSTALL_OSUPDATES=1
INSTALL_SLAMDATA=1


# ======== Variables ========
SLAMDATA_DOWNLOAD_REDIRECT=http://slamdata.com/download/thinkbox-installer-2/?wpdmdl=3442
SLAMDATA_INSTALLER_FILENAME=slamdata_unix_2_5_6.sh


# ======== Update ========
export DEBIAN_FRONTEND=noninteractive

if [[ $INSTALL_OSUPDATES ]] && [[ $INSTALL_OSUPDATES -eq 1 ]]
then
    printf "Running OS updates...\n"
    sudo apt-get update 
    sudo apt-get -y upgrade
fi


# ======== SlamData ========
if [[ $INSTALL_SLAMDATA ]] && [[ $INSTALL_SLAMDATA -eq 1 ]]
then
    printf "Installing openjdk-8-jre...\n"
 
    # Install required JRE 1.8
    sudo apt-get install -y openjdk-8-jre
    java -version

    cd /home/vagrant/Downloads
    printf "Fetching SlamData Installer...\n"
    wget --no-verbose --max-redirect=10 -O$SLAMDATA_INSTALLER_FILENAME $SLAMDATA_DOWNLOAD_REDIRECT
    sudo chmod +x $SLAMDATA_INSTALLER_FILENAME

    printf "Installing SlamData...\n"
    # Need to pipe in the responses.  
    printf 'o\n/opt/slamdata-2.5.6\ny\n\n' | ./$SLAMDATA_INSTALLER_FILENAME
    
    rm -f SLAMDATA_INSTALLER_FILENAME
fi

# ======== Done ========
printf "End of slamdata-vm-provisioner.sh script.\n\n"
