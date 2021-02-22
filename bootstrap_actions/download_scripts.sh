# Necessary minimal setup for this script to run
sudo mkdir -p /var/log/pdm
sudo mkdir -p /opt/emr
sudo chown hadoop:hadoop /var/log/pdm
sudo chown hadoop:hadoop /opt/emr
export PDM_LOG_LEVEL="${PDM_LOG_LEVEL}"

echo "${VERSION}" > /opt/emr/version
echo "${PDM_LOG_LEVEL}" > /opt/emr/log_level
echo "${ENVIRONMENT_NAME}" > /opt/emr/environment

# Download the logging scripts
$(which aws) s3 cp "${S3_COMMON_LOGGING_SHELL}"  /opt/shared/common_logging.sh
$(which aws) s3 cp "${S3_LOGGING_SHELL}"         /opt/emr/logging.sh

# Set permissions
chmod u+x /opt/shared/common_logging.sh
chmod u+x /opt/emr/logging.sh

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