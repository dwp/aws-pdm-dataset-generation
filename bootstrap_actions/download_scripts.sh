# Necessary minimal setup for this script to run
sudo mkdir -p /var/log/pdm
sudo chown hadoop:hadoop /var/log/pdm

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "download_scripts.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    log_wrapper_message "Create directory for the files"
    sudo mkdir -p /var/ci
    sudo chown hadoop:hadoop /var/ci

    log_wrapper_message "Downloading & install latest bootstrap and steps scripts"
    $(which aws) s3 cp ${scripts_location}/ /var/ci/ --include "*.sh"

    log_wrapper_message "Downloading & install latest metrics scripts"
    $(which aws) s3 cp ${metrics_scripts_location}/ /var/ci/ --include "*.sh"

    log_wrapper_message "Apply recursive execute permissions to the folder"
    sudo chmod --recursive a+rx /var/ci

    log_wrapper_message "Script downloads completed"

)  >> /var/log/pdm/download_scripts.log 2>&1