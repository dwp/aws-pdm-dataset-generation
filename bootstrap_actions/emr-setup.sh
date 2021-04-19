#!/usr/bin/env bash
echo "Creating directories"
sudo mkdir -p /opt/emr/sql
sudo mkdir -p /opt/emr/sql/extracted
sudo chown hadoop:hadoop /opt/emr/sql
sudo chown hadoop:hadoop /opt/emr/sql/extracted

echo "Installing scripts"
$(which aws) s3 cp "${RESUME_STEP_SHELL}"                   /opt/emr/resume_step.sh
$(which aws) s3 cp "${S3_CLOUDWATCH_SHELL}"                 /opt/emr/cloudwatch.sh
$(which aws) s3 cp "${S3_RETRY_UTILITY}"                    /opt/emr/retry.sh
$(which aws) s3 cp "${S3_RETRY_SCRIPT}"                     /opt/emr/with_retry.sh

echo "Changing the Permissions"
chmod u+x /opt/emr/resume_step.sh
chmod u+x /opt/emr/cloudwatch.sh
chmod u+x /opt/emr/with_retry.sh

(
# Import the logging functions
source /opt/emr/logging.sh

function log_wrapper_message() {
    log_pdm_message "$${1}" "emr-setup.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
}

log_wrapper_message "Setting up the Proxy"

echo -n "Running as: "
whoami

export AWS_DEFAULT_REGION=${aws_default_region}

FULL_PROXY="${full_proxy}"
FULL_NO_PROXY="${full_no_proxy}"
export http_proxy="$FULL_PROXY"
export HTTP_PROXY="$FULL_PROXY"
export https_proxy="$FULL_PROXY"
export HTTPS_PROXY="$FULL_PROXY"
export no_proxy="$FULL_NO_PROXY"
export NO_PROXY="$FULL_NO_PROXY"
export PDM_LOG_LEVEL="${PDM_LOG_LEVEL}"

echo "Setup cloudwatch logs"
sudo /opt/emr/cloudwatch.sh \
    "${cwa_metrics_collection_interval}" "${cwa_namespace}"  "${cwa_log_group_name}" \
    "${aws_default_region}" "${cwa_bootstrap_loggrp_name}" "${cwa_steps_loggrp_name}" \
    "${cwa_yarnspark_loggrp_name}" "${cwa_hive_loggrp_name}" "${cwa_tests_loggrp_name}"

log_wrapper_message "Getting the DKS Certificate Details "

## get dks cert
trust_store_pass=$(uuidgen -r)
key_store_pass=$(uuidgen -r)
key_pass=$(uuidgen -r)
acm_pass=$(uuidgen -r)

export TRUSTSTORE_PASSWORD="$trust_store_pass"
export KEYSTORE_PASSWORD="$key_store_pass"
export PRIVATE_KEY_PASSWORD="$key_pass"
export ACM_KEY_PASSWORD="$acm_pass"

#sudo mkdir -p /opt/emr
#sudo chown hadoop:hadoop /opt/emr
touch /opt/emr/dks.properties
cat >> /opt/emr/dks.properties <<EOF
identity.store.alias=${private_key_alias}
identity.key.password=$PRIVATE_KEY_PASSWORD
spark.ssl.fs.enabled=true
spark.ssl.keyPassword=$KEYSTORE_PASSWORD
identity.keystore=/opt/emr/keystore.jks
identity.store.password=$KEYSTORE_PASSWORD
trust.keystore=/opt/emr/truststore.jks
trust.store.password=$TRUSTSTORE_PASSWORD
data.key.service.url=${dks_endpoint}
EOF

log_wrapper_message "Retrieving the ACM Certificate details"

acm-cert-retriever \
    --acm-cert-arn "${acm_cert_arn}" \
    --acm-key-passphrase "$ACM_KEY_PASSWORD" \
    --keystore-path "/opt/emr/keystore.jks" \
    --keystore-password "$KEYSTORE_PASSWORD" \
    --private-key-alias "${private_key_alias}" \
    --private-key-password "$PRIVATE_KEY_PASSWORD" \
    --truststore-path "/opt/emr/truststore.jks" \
    --truststore-password "$TRUSTSTORE_PASSWORD" \
    --truststore-aliases "${truststore_aliases}" \
    --truststore-certs "${truststore_certs}" \
    --jks-only true >> /var/log/pdm/acm-cert-retriever.log 2>&1

#shellcheck disable=SC2024
sudo -E acm-cert-retriever \
    --acm-cert-arn "${acm_cert_arn}" \
    --acm-key-passphrase "$ACM_KEY_PASSWORD" \
    --private-key-alias "${private_key_alias}" \
    --truststore-aliases "${truststore_aliases}" \
    --truststore-certs "${truststore_certs}"  >> /var/log/pdm/acm-cert-retriever.log 2>&1 # No sudo needed to write to file, so redirect is fine

cd /etc/pki/ca-trust/source/anchors/ || exit
sudo touch pdm_ca.pem
sudo chown hadoop:hadoop /etc/pki/tls/private/"${private_key_alias}".key /etc/pki/tls/certs/"${private_key_alias}".crt /etc/pki/ca-trust/source/anchors/pdm_ca.pem
TRUSTSTORE_ALIASES="${truststore_aliases}"
#shellcheck disable=SC2001
for F in $(echo "$TRUSTSTORE_ALIASES" | sed "s/,/ /g"); do #Shellcheck wants to not use sed for POSIX compliance but is ok here as it works
 (sudo cat "$F.crt"; echo) >> pdm_ca.pem;
done

UUID=$(dbus-uuidgen | cut -c 1-8)
TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" "http://169.254.169.254/latest/api/token")
instance_id=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
instance_role=$(jq .instanceRole /mnt/var/lib/info/extraInstanceData.json)
host="${name}-$${INSTANCE_ROLE//\"}-$UUID"
export INSTANCE_ID="$instance_id"
export INSTANCE_ROLE="$instance_role"
export HOSTNAME="$host"

sudo hostnamectl set-hostname "$HOSTNAME"
$(which aws) ec2 create-tags --resources "$INSTANCE_ID" --tags Key=Name,Value="$HOSTNAME"

log_wrapper_message "Downloading and running dynamo updater script"
$(which aws) s3 cp "${update_dynamo_sh}"                    /opt/emr/update_dynamo.sh
$(which aws) s3 cp "${dynamo_schema_json}"                  /opt/emr/dynamo_schema.json

chmod u+x /opt/emr/update_dynamo.sh

/opt/emr/update_dynamo.sh &

log_wrapper_message "Downloading and running status metrics script"
$(which aws) s3 cp "${status_metrics_sh}"                    /opt/emr/status_metrics.sh

chmod u+x /opt/emr/status_metrics.sh

/opt/emr/status_metrics.sh &

log_wrapper_message "Completed the emr-setup.sh step of the EMR Cluster"

) >> /var/log/pdm/emr_setup.log 2>&1
