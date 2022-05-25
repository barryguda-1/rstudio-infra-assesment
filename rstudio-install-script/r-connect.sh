#!/bin/bash
#This script is used for auto-deployment of r-connect
export R_VERSION=4.1.3

function installR() {
    ##Using CentOS 7 rpm files
    ##iterate to ceheck if commands exist
    curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm
    sudo amazon-linux-extras install epel -y
    #Install identified dependency for Amazon 2
    sudo yum install -y openblas
    sudo yum install -y R-${R_VERSION}-1-1.x86_64.rpm

    ##add logic to check if successfully installed
}

function checkR() {
    R_DIR="/opt/R/$R_VERSION/bin/R"
    RSCRIPT_DIR="/opt/R/$R_VERSION/bin/Rscript"
    if [[ -e ${R_DIR} && -e ${RSCRIPT_DIR} ]]; then
        echo "====Congrtulations R is installed===="
    else
        echo "====Sorry R has not been installed Succesfully please check logs!===="

        exit 1
    fi

}
function createSymlinks() {
    sudo ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R
    sudo ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript
}

function installRstudio() {
    curl -O https://cdn.rstudio.com/connect/2022.04/rstudio-connect-2022.04.2.amazonlinux2.x86_64.rpm
    sudo yum install -y rstudio-connect-2022.04.2.amazonlinux2.x86_64.rpm

    ##add logic to check if Rstudio is running
}

function checkRunning() {
    running="$(systemctl status rstudio-connect | grep running | awk '{ print $3 }' | sed -e 's/(//g' -e 's/)//g')"

    if [ ${running} == 'running' ]; then
        echo "====Congratulations R Studio is up and running===="
        echo ""
        for ip in $(ip addr | grep 'state UP' -A2 | grep inet | awk '{print $2}' | cut -f1 -d/); do
            echo "    http://${ip}:3939/"
        done
        echo -e "\nIf you are using a reverse SSH tunnel please try the following:
        http://localhost:3939/"
    else
        echo "====Check log file for failure===="

    fi


}

installR
checkR
createSymlinks
installRstudio
checkRunning

##remember to output to logfile
