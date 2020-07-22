SCRIPT_DIR=/opt/sql/extracted
SOURCE_DIR=$SCRIPT_DIR/source
TRANSFORM_DIR=$SCRIPT_DIR/transform
MODEL_DIR=$SCRIPT_DIR/model

echo "Download & install latest pdm scripts"
VERSION="${VERSION}"
URL="s3://${s3_artefact_bucket_id}/dataworks/pdm.zip"
$(which aws) s3 cp $URL /opt/sql
echo "PDM_VERSION: $VERSION"
echo "SCRIPT_DOWNLOAD_URL: $URL"
echo "$VERSION" > /opt/emr/version
echo "${PDM_LOG_LEVEL}" > /opt/emr/log_level
echo "${ENVIRONMENT_NAME}" > /opt/emr/environment

#Extract files
unzip /opt/sql/pdm.zip -d $SCRIPT_DIR

echo "Consolidating SQL Scripts"
#####################
# Build Source Script
#####################

if [ -f $SOURCE_DIR/source.sql ]
then
	rm $SOURCE_DIR/source.sql
fi

for f in $SOURCE_DIR/*.sql
do
    (cat "${f}"; echo '') >> $SOURCE_DIR/source.sql
done

#########################
# Build Transform Script
#########################

if [ -f $TRANSFORM_DIR/transform.sql ]
then
	rm $TRANSFORM_DIR/transform.sql
fi

for f in $TRANSFORM_DIR/*.sql
do
    (cat "${f}"; echo '') >> $TRANSFORM_DIR/transform.sql
done

########################
# Build Model Script
########################

if [ -f $MODEL_DIR/model.sql ]
then
	rm $MODEL_DIR/model.sql
fi

for f in $MODEL_DIR/*.sql
do
    (cat "${f}"; echo '') >> $MODEL_DIR/model.sql
done

#copy source to S3
aws s3 cp $SOURCE_DIR/source.sql ${s3_config_bucket}

#copy tranform to S3
aws s3 cp $TRANSFORM_DIR/transform.sql ${s3_config_bucket}

#copy model to S3
aws s3 cp $MODEL_DIR/model.sql ${s3_config_bucket}