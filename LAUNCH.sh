#!/usr/bin/env bash

REPO_DIR=$(dirname $(realpath "$0"))

$REPO_DIR/LaunchWorkflow.sh \
	-s local \
	-p defaults \
	-x paths \
	-b s3://core-547154048962-eu-west-2/nextflow \
	-i $REPO_DIR/pipeline/inputs/test/SampleInfoTestS3.tsv $@
