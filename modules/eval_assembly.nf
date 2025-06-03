process merqury{
    input:
    tuple path(hapmers_dad), path(hapmers_mom), path(hapmers_shared)
    path(meryl_child_lr)
    path(hap_mom_fastq)
    path(hap_dad_fastq)
    output:
    path("merqury_result.txt"), emit: result
    script:
    if (params.debug){
        """
        echo "merqury" > merqury_result.txt
        """
    }
    else{
        """
        merqury.sh ${meryl_child_lr} ${hapmers_mom} ${hapmers_dad} ${hap_mom_fastq} \\
        ${hap_dad_fastq} merqury_result.txt OMP_NUM_THREADS=$task.cpus
        """
    }
}