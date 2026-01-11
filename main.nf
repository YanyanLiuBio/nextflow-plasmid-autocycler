nextflow.enable.dsl=2

include { AUTOCYCLER } from './modules/autocycler.nf'

workflow {

    Channel
        .fromPath(params.input)
        .map { it -> tuple(it.baseName.replace(".fastq", ""), it) }
        .set { reads_ch }

    AUTOCYCLER(reads_ch)
}
