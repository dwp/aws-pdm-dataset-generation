#!/bin/bash
#################
# Set Variables
#################

DICTIONARY_LOCATION="${dictionary_location}"

(
    STEP_TO_START_FROM_FILE=/opt/emr/step_to_start_from.txt
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "clean_dictionary_data.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

 # Import retry function
    source /opt/emr/retry.sh
    check_retry

    log_wrapper_message "Uploading initialOrganisation.json "
    aws s3 cp $DICTIONARY_LOCATION/unclean/site/initialOrganisation.json /opt/emr/sql/initialOrganisation.json
    tr -d '\n' < /opt/emr/sql/initialOrganisation.json > /opt/emr/sql/initialOrganisation_tmp.json
    aws s3 cp /opt/emr/sql/initialOrganisation_tmp.json $DICTIONARY_LOCATION/site/initialOrganisation.json

    log_wrapper_message "Uploading initialOrganisation-NorthernIreland.json "
    aws s3 cp $DICTIONARY_LOCATION/unclean/site/initialOrganisation-NorthernIreland.json /opt/emr/sql/initialOrganisation-NorthernIreland.json
    tr -d '\n' < /opt/emr/sql/initialOrganisation-NorthernIreland.json > /opt/emr/sql/initialOrganisation-NorthernIreland_tmp.json
    aws s3 cp /opt/emr/sql/initialOrganisation-NorthernIreland_tmp.json $DICTIONARY_LOCATION/site/initialOrganisation-NorthernIreland.json


    log_wrapper_message "Uploading initialDeliveryUnitAddresses_tagged "
    aws s3 cp $DICTIONARY_LOCATION/unclean/data/address/initialDeliveryUnitAddresses.json /opt/emr/sql/initialDeliveryUnitAddresses.json
    tr -d '\n' < /opt/emr/sql/initialDeliveryUnitAddresses.json > /opt/emr/sql/initialDeliveryUnitAddresses_tmp.json
    ex -sc '1i|{"addresses" : ' -cx /opt/emr/sql/initialDeliveryUnitAddresses_tmp.json
    echo "}" >> /opt/emr/sql/initialDeliveryUnitAddresses_tmp.json
    tr -d '\n' < /opt/emr/sql/initialDeliveryUnitAddresses_tmp.json > /opt/emr/sql/initialDeliveryUnitAddresses_tagged.json
    aws s3 cp /opt/emr/sql/initialDeliveryUnitAddresses_tagged.json $DICTIONARY_LOCATION/address_tagged/initialDeliveryUnitAddresses_tagged.json


    log_wrapper_message "Uploading initialDeliveryUnitAddresses_tagged "
    aws s3 cp $DICTIONARY_LOCATION/unclean/data/address/initialDeliveryUnitAddresses.json /opt/emr/sql/initialDeliveryUnitAddresses.json
    tr -d '\n' < /opt/emr/sql/initialDeliveryUnitAddresses.json > /opt/emr/sql/initialDeliveryUnitAddresses_tmp.json
    aws s3 cp /opt/emr/sql/initialDeliveryUnitAddresses.json $DICTIONARY_LOCATION/data/address/initialDeliveryUnitAddresses.json

    log_wrapper_message "Finish clean_dictionary_data.sh"
    




) >> /var/log/pdm/clean_dictionary_data.log 2>&1


