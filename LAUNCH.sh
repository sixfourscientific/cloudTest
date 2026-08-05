#!/usr/bin/env bash

REPO_DIR=$(dirname $(realpath "$0"))

$REPO_DIR/LaunchWorkflow.sh \
	-s awsbatch \
	-p defaults \
	-x data \
	-r launch_awsbatch_defaults_2026.08.05_14.29.48 \
	-b s3://core-547154048962-eu-west-2/nextflow-TEST \
	-i $REPO_DIR/pipeline/inputs/test/SampleInfoTestLocal.tsv $@
