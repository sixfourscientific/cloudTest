#!/usr/bin/env bash

echo "~ RUNNING VIA SCRIPT ~"

nextflow \
    -C pipeline/nextflow.config \
    run pipeline/stem.nf \
    -latest \
    -profile login \
    -params-file pipeline/params/defaults.json \
    --execute all \
    --inputs pipeline/inputs/test/SampleInfoTestS3.tsv \
    --supplementary ''
