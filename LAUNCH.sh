#!/usr/bin/env bash

REPO_DIR=$(dirname $(realpath "$0"))

#BUCKET="-b s3://core-547154048962-eu-west-2/nextflow"
BUCKET="-b gs://core-sixfourscientific-europe-west2/nextflow"

$REPO_DIR/LaunchWorkflow.sh \
	-s googlebatch \
	-p defaults \
	-x data \
	$BUCKET \
	-i $REPO_DIR/pipeline/inputs/test/SampleInfoTestLocal.tsv $@
