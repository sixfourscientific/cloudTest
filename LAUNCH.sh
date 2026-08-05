#!/usr/bin/env bash

REPO_DIR=$(dirname $(realpath "$0"))

$REPO_DIR/LaunchWorkflow.sh \
	-s awsbatch \
	-p defaults \
	-x data \
	-r launch_awsbatch_defaults_2026.08.05_08.03.20 \
	-i $REPO_DIR/pipeline/inputs/test/SampleInfoTestLocal.tsv $@
