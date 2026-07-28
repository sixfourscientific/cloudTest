#!/usr/bin/env bash

echo "~ RUNNING VIA SCRIPT ~"

nextflow \
    -C pipeline/nextflow.config \
    run pipeline/stem.nf \
    -latest \
    -profile local \
    -params-file pipeline/params/defaults.json \
    --execute data \
    --inputs pipeline/inputs/test/SampleInfoTestLocal.tsv \
    --supplementary ''
