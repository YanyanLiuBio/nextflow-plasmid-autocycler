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
