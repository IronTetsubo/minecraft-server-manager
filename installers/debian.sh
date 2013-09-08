UPDATE_URL="https://raw.github.com/marcuswhybrow/minecraft-server-manager/master"

which wget >/dev/null 2>&1
if [[ $? != 1 ]]; then
    DOWNLOAD_BIN="wget -q -O - "
else
    which curl >/dev/null 2>&1
    if [[ $? != 1 ]]; then
        DOWNLOAD_BIN="curl -s -L "
    else
        echo "No download utility found! Please make sure either wget or curl are installed on this system."
	exit 1
    fi
fi
${DOWNLOAD_BIN} ${UPDATE_URL}/installers/common.sh > /tmp/msmcommon.sh
source /tmp/msmcommon.sh && rm -f /tmp/msmcommon.sh

function update_system_packages() {
    install_log "Updating sources"
    sudo apt-get update || install_error "Couldn't update package list"
    sudo apt-get upgrade || install_error "Couldn't upgrade packages"
}

function install_dependencies() {
    install_log "Installing required packages"
    sudo apt-get install screen rsync zip || install_error "Couldn't install dependencies"
}

function reload_cron() {
    install_log "Reloading cron service"
    hash service 2>/dev/null
    if [[ $? == 0 ]]; then
        sudo service cron reload
    else
        sudo /etc/init.d/cron reload
    fi
}

function enable_init() {
    install_log "Enabling automatic startup and shutdown"
    hash insserv 2>/dev/null
    if [[ $? == 0 ]]; then
        sudo insserv msm
    else
        sudo update-rc.d msm defaults
    fi
}

install_msm
