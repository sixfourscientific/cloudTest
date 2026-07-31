#!/usr/bin/env bash

REPO_DIR=$(dirname $(realpath "$0"))

$REPO_DIR/LaunchWorkflow.sh \
	-s aws_batch \
	-p defaults \
	-x data \
	-o s3://test-547154048962-eu-north-1/nextflow-outputs \
	-w s3://test-547154048962-eu-north-1/nextflow-work \
	-i $REPO_DIR/pipeline/inputs/test/SampleInfoTestLocal.tsv $@
