#!/usr/bin/env bash

REPO_DIR=$(dirname $(realpath "$0"))

SYSTEM="googlebatch"

if [[ "$SYSTEM" == awsbatch ]]; then
	BUCKET="-b s3://core-547154048962-eu-west-2/nextflow"
elif [[ "$SYSTEM" == googlebatch ]]; then
	BUCKET="-b gs://core-sixfourscientific-europe-west2/nextflow"
else
	BUCKET=""
fi

$REPO_DIR/LaunchWorkflow.sh \
	-s $SYSTEM \
	-p defaults \
	-x data \
	$BUCKET \
	-i $REPO_DIR/pipeline/inputs/test/SampleInfoTestLocal.tsv $@
