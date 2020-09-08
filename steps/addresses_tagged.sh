#!/bin/bash
###############
# Set Variables
###############

DICTIONARY_LOCATION="${dictionary_location}"

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "addresses_tagged.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }
    ##############################
    # Create addresses_tagged.json
    ##############################

    echo "START_CREATING_ADDRESSES_TAGGED_JSON ......................"
    log_wrapper_message "start addresses_tagged_json ......................."

    aws s3 cp $DICTIONARY_LOCATION/data/address/initialDeliveryUnitAddresses.json /opt/emr/sql
    tr -d '\n' < /opt/emr/sql/initialDeliveryUnitAddresses.json > /opt/emr/sql/initialDeliveryUnitAddresses_tagged.json
    aws s3 cp /opt/emr/sql/initialDeliveryUnitAddresses_tagged.json $DICTIONARY_LOCATION/address_tagged
    
    echo "FINISH_CREATING_ADDRESSES_TAGGED_JSON ......................"
    log_wrapper_message "Finish_creating_addresses_tagged_json......................."

) >> /var/log/pdm/addresses_tagged.log 2>&1


