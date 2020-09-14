#!/bin/bash
#################
# Set Variables
#################

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

    echo "START_CLEANING_DICTIONARY_DATA ......................"
 
    # GB - Sites #
    log_wrapper_message "start cleaning GB Site  ......................."

    aws s3 cp $DICTIONARY_LOCATION/site/initialOrganisation.json /opt/emr/sql/initialOrganisation.json
    tr -d '\n' < /opt/emr/sql/initialOrganisation.json > /opt/emr/sql/initialOrganisation.json
    aws s3 cp /opt/emr/sql/initialOrganisation.json $DICTIONARY_LOCATION/site/initialOrganisation.json

    log_wrapper_message "finish cleaning GB Site  ......................."

    # NI - Sites #
    log_wrapper_message "start cleaning NI Site  ......................."
    
    aws s3 cp $DICTIONARY_LOCATION/site/initialOrganisation-NorthernIreland.json /opt/emr/sql/initialOrganisation-NorthernIreland.json
    tr -d '\n' < /opt/emr/sql/initialOrganisation-NorthernIreland.json > /opt/emr/sql/initialOrganisation-NorthernIreland.json
    aws s3 cp /opt/emr/sql/initialOrganisation-NorthernIreland.json $DICTIONARY_LOCATION/site/initialOrganisation-NorthernIreland.json

    log_wrapper_message "finish cleaning NI Site  ......................."

    # Get Address file
    log_wrapper_message "start cleaning address file  ......................."

    aws s3 cp $DICTIONARY_LOCATION/data/address/initialDeliveryUnitAddresses.json /opt/emr/sql/initialDeliveryUnitAddresses.json
    tr -d '\n' < /opt/emr/sql/initialDeliveryUnitAddresses.json > /opt/emr/sql/initialDeliveryUnitAddresses.json

    log_wrapper_message "finish cleaning address file   ......................."
    
    # Addresses #
    log_wrapper_message "start copying address file back to s3  ......................."

    aws s3 cp /opt/emr/sql/initialDeliveryUnitAddresses.json $DICTIONARY_LOCATION/data/address/initialDeliveryUnitAddresses.json

    log_wrapper_message "finish copying address file back to s3  ......................."

    # Addresses_tagged
    log_wrapper_message "start creating addresses_tagged  ......................."

    ex -sc '1i|{"addresses" : ' -cx /opt/emr/sql/initialDeliveryUnitAddresses.json
    echo "}" >> /opt/emr/sql/initialDeliveryUnitAddresses.json
    tr -d '\n' < /opt/emr/sql/initialDeliveryUnitAddresses.json > /opt/emr/sql/initialDeliveryUnitAddresses_tagged.json
    aws s3 cp /opt/emr/sql/initialDeliveryUnitAddresses_tagged.json $DICTIONARY_LOCATION/address_tagged/initialDeliveryUnitAddresses_tagged.json

    log_wrapper_message "finish creating address_tagged  ......................."
    
    echo "FINISH_CLEANING_DICTIONARY_DATA ......................"
    log_wrapper_message "Finish_cleaning_data_dictionary_data......................."

) >> /var/log/pdm/addresses_tagged.log 2>&1


