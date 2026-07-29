#!/usr/bin/env bash

REPO_DIR=$(dirname $(realpath "$0"))

$REPO_DIR/LaunchWorkflow.sh \
	-s local \
	-p defaults \
	-x all \
    -w ~/NEXTFLOW/workk \
    -r launch_local_defaults_2026.07.28_21.02.03 \
	-i $REPO_DIR/pipeline/inputs/test/SampleInfoTestLocal.tsv $@


