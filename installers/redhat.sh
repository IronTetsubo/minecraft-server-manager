# Redhat (Fedora/RHEL) specific install function overrides.

function update_system_packages() {
    install_log "Updating sources"
    sudo yum update || install_error "Couldn't update packages"
}

function install_dependencies() {
    install_log "Installing required packages"
    sudo yum install screen rsync zip || install_error "Couldn't install dependencies"
}

function install_init() {
    install_log "Installing MSM init file"
    which systemd >/dev/null 2>&1
    if [[ $? != 1 ]]; then
        install_log "Detected systemd, installing systemd service file."
        sudo install -b "$dl_dir/msm.init" /usr/local/bin/msm || install_error "Couldn't install command file"
        sudo install -b "$dl_dir/msm.service" /usr/lib/systemd/system/msm.service || install_error "Couldn't install service file"
    else
        sudo install -b "$dl_dir/msm.init" /etc/init.d/msm || install_error "Couldn't install init file"

        install_log "Making MSM accessible as the command 'msm'"
        sudo ln -s /etc/init.d/msm /usr/local/bin/msm
    fi
}

function enable_init() {
    install_log "Enabling automatic startup and shutdown"
    which systemd >/dev/null 2>&1
    if [[ $? != 1 ]]; then
        install_log "Detected systemd, enabling systemd service file."
        /usr/bin/systemctl enable msm.service >/dev/null 2>&1 || :
    else
        sudo chkconfig --add msm       
    fi
}
