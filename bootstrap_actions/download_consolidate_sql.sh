SCRIPT_DIR=/opt/emr/sql/extracted 

echo "Download & install latest pdm scripts"
VERSION="${version}"
URL="s3://${s3_artefact_bucket_id}/dataworks-pdm/dataworks-pdm-$VERSION.zip"
$(which aws) s3 cp $URL /opt/emr/sql
echo "PDM_VERSION: $VERSION"
echo "SCRIPT_DOWNLOAD_URL: $URL"
echo "$version" > /opt/emr/version
echo "${pdm_log_level}" > /opt/emr/log_level
echo "${environment_name}" > /opt/emr/environment

SOURCE_DIR=$SCRIPT_DIR/src/main/resources/scripts/source
TRANSFORM_DIR=$SCRIPT_DIR/src/main/resources/scripts/transform
MODEL_DIR=$SCRIPT_DIR/src/main/resources/scripts/model

#Extract files
unzip /opt/emr/sql/dataworks-pdm-$VERSION.zip -d $SCRIPT_DIR /opt/emr/sql/extracted/

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
    (cat $f; echo '') >> $SOURCE_DIR/source.sql
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
    (cat $f; echo '') >> $TRANSFORM_DIR/transform.sql
done

########################
# Build Model Script
########################

if [ -f $MODEL_DIR/model.sql ]
then
	rm $MODEL_DIR/model.sql
fi

for n in {1..9}
do
    for f in "$MODEL_DIR"/*$n".sql"
    do
        (cat "$f"; echo '') >> $MODEL_DIR/model.sql
    done
done

#copy source to S3
aws s3 cp $SOURCE_DIR/source.sql ${s3_config_bucket_id}/component/pdm-dataset-generation/source.sql

#copy transform to S3
aws s3 cp $TRANSFORM_DIR/transform.sql ${s3_config_bucket_id}/component/pdm-dataset-generation/transform.sql

#copy model to S3
aws s3 cp $MODEL_DIR/model.sql ${s3_config_bucket_id}/component/pdm-dataset-generation/model.sql

