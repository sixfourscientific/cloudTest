#!/usr/bin/env bash

REPO_DIR=$(dirname $(realpath "$0"))

$REPO_DIR/LaunchWorkflow.sh \
	-s awsbatch \
	-p defaults \
	-x data \
	-b s3://core-547154048962-eu-west-2/nextflow-TEST \
	-i $REPO_DIR/pipeline/inputs/test/SampleInfoTestLocal.tsv $@
