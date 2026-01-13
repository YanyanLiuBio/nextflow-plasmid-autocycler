process AUTOCYCLER {
    tag "${pair_id}"
    errorStrategy 'ignore'
    publishDir "${params.output}", mode: 'copy', pattern: "${pair_id}*"
   

    input:
      tuple val(pair_id), path(fq), val(length)


    output:
      tuple val(pair_id), path("*")

    script:
    """
    autocycler_full.sh ${fq} ${length} ${params.threads} ${params.jobs}
    mv assemblies ${pair_id}_assemblies
    mv autocycler_out ${pair_id}_autocycler_out
    cp ${pair_id}_autocycler_out/consensus_assembly.fasta ${pair_id}_consensus_assembly.fasta
    
    mkdir -p ${pair_id}
    mv ${pair_id}_* ${pair_id}
    
    """
}
