SCRIPT_DIR=/opt/sql/dataworks-pdm/src/main/resources
SOURCE_DIR=$SCRIPT_DIR/source
TRANSFORM_DIR=$SCRIPT_DIR/transform
MODEL_DIR=$SCRIPT_DIR/model

echo "Download & install latest pdm scripts service artifact"
VERSION="${VERSION}"
URL="s3://${s3_artefact_bucket_id}/pdm/*"
$(which aws) s3 cp $URL /opt/sql
echo "PDM_VERSION: $VERSION"
echo "SCRIPT_DOWNLOAD_URL: $URL"
echo "$VERSION" > /opt/emr/version
echo "${PDM_LOG_LEVEL}" > /opt/emr/log_level
echo "${ENVIRONMENT_NAME}" > /opt/emr/environment

echo "Consolidating SQL Scripts"
#####################
# Build Source Script
#####################

if [ -f $SOURCE_DIR/source.sql ]
then
	rm $SOURCE_DIR/source.sql
fi


for f in $SCRIPT_DIR/source/*.sql
do
    (cat "${f}"; echo '') >> $SOURCE_DIR/source.sql
done

#########################
# Build Transform Script
#########################


########################
# Build Model Script
########################