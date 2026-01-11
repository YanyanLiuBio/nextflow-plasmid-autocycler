process AUTOCYCLER {
    tag "${pair_id}"
    
    publishDir "output", mode: 'copy'
    

    input:
      tuple val(pair_id), path(fq)


    output:
      tuple val(pair_id), path("*")

    script:
    """
    autocycler_full.sh ${fq} ${params.threads} ${params.jobs}
    """
}
