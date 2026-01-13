# Autocycler Nextflow Pipeline


[![Nextflow Workflow Tests](https://https://github.com/YanyanLiuBio/nextflow-plasmid-autocycler/actions/workflows/nextflow-ci.yml/badge.svg?branch=main)](https://https://github.com/YanyanLiuBio/nextflow-plasmid-autocycler/actions/workflows/nextflow-ci.yml?query=branch%3Amain)
[![Nextflow](https://img.shields.io/badge/Nextflow%20DSL2-%E2%89%A523.04.0-blue.svg)](https://www.nextflow.io/)


This workflow is a lightweight Nextflow DSL2 wrapper around the
[Autocycler](https://github.com/rrwick/Autocycler) tool for long-read
plasmid assembly.

It takes a set of FASTQ files and a metadata CSV, matches each sample to
its expected plasmid length, and runs Autocycler on each sample in
parallel.

``` nextflow
nextflow.enable.dsl=2

include { AUTOCYCLER } from './modules/autocycler.nf'

workflow {

    reads_ch = Channel
        .fromPath(params.input)
        .map { fq ->
            def sample_id = fq.baseName.replaceFirst(/\.fastq(\.gz)?$/, '')
            tuple(sample_id, fq)
        }

    // CSV inputs -> (sample_id, length)
    meta_ch = Channel
        .fromPath(params.meta)          // e.g. params.meta = "samples.csv"
        .splitCsv(header: true)
        .map { row ->
            tuple(row.sample_id, (row.length as Double).intValue())
        }

    merged_ch = reads_ch
        .join(meta_ch)

    AUTOCYCLER(merged_ch)
}
```

------------------------------------------------------------------------

## Inputs

This pipeline expects two inputs:

1.  **FASTQ files** (long-read data)

    ``` bash
    --input "reads/*.fastq.gz"
    ```

    Each file is treated as one sample. The `sample_id` is derived from
    the filename (with `.fastq` or `.fastq.gz` removed).

2.  **Metadata CSV**

    ``` bash
    --meta samples.csv
    ```

    The CSV must contain a header and at least these columns:

    ``` csv
    sample_id,length
    BC_01,5200
    BC_02,4800
    BC_03,6100
    ```

    -   `sample_id` must match the FASTQ base name.
    -   `length` is the expected plasmid length for that sample.

The workflow joins the FASTQ channel with the CSV channel so that each
sample is passed to Autocycler as:

    (sample_id, fastq, plasmid_length)

------------------------------------------------------------------------

## Running the Pipeline

Example: default is using Docker

``` bash
nextflow run main.nf \
  --input "reads/*.fastq.gz" \
  --meta samples.csv \
  --output output \
  -bg -resume
```

------------------------------------------------------------------------

## Important Notes

This pipeline is **adapted from the original Autocycler GitHub tool**
with the following key changes:

1.  **User-provided plasmid length**\
    The original Autocycler workflow infers or estimates size
    internally.\
    This pipeline requires the user to explicitly provide the expected
    plasmid length per sample via a CSV file, enabling better control
    and reproducibility.

2.  **Containerized Autocycler**\
    A dedicated Docker image is used for Autocycler and its
    dependencies, making the workflow portable across local machines,
    clusters, and cloud platforms.

3.  **Nextflow-based Pipeline**\
    The original shell-based workflow is wrapped as a modular Nextflow
    DSL2 pipeline:

    -   Samples are processed in parallel.
    -   Inputs are cleanly modeled as channels.
    -   The pipeline is reproducible, portable, and scheduler/cloud
        friendly.

This design makes Autocycler easier to integrate into larger Nextflow
workflows and production environments.

