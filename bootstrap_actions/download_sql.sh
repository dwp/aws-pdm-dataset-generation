#!/bin/bash
(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "download_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    SCRIPT_DIR=/opt/emr/sql/extracted

    echo "Download & install latest pdm scripts"
    log_wrapper_message "Downloading & install latest pdm scripts"

    VERSION="${version}"
    URL="s3://${s3_artefact_bucket_id}/dataworks-pdm/dataworks-pdm-$VERSION.zip"
    "$(which aws)" s3 cp $URL /opt/emr/sql

    echo "PDM_VERSION: $VERSION"
    log_wrapper_message "pdm_version: $VERSION"

    echo "SCRIPT_DOWNLOAD_URL: $URL"
    log_wrapper_message "script_download_url: $URL"

    echo "Unzipping location: $SCRIPT_DIR"
    log_wrapper_message "script unzip location: $SCRIPT_DIR"

    echo "$version" > /opt/emr/version
    echo "${pdm_log_level}" > /opt/emr/log_level
    echo "${environment_name}" > /opt/emr/environment

    echo "START_UNZIPPING ......................"
    log_wrapper_message "start unzipping ......................."

    unzip /opt/emr/sql/dataworks-pdm-"$VERSION".zip -d $SCRIPT_DIR  >> /var/log/pdm/download_unzip_sql.log 2>&1

    echo "FINISHED UNZIPPING ......................"
    log_wrapper_message "finished unzipping ......................."

)  >> /var/log/pdm/download_sql.log 2>&1