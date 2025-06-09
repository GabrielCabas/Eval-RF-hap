process merqury{
    publishDir "$params.outdir/merqury/", mode: "copy"
    input:
    tuple path(hapmers_dad), path(hapmers_mom)
    path(meryl_child_sr)
    path(hap_mom_fastq)
    path(hap_dad_fastq)
    output:
    path("merqury_result*"), emit: result
    script:
    if (params.debug){
        """
        echo "merqury" > merqury_result.txt
        """
    }
    else{
        """
        export MERQURY=/opt/conda/share/merqury
        \$MERQURY/merqury.sh ${meryl_child_sr} ${hapmers_mom} ${hapmers_dad} ${hap_mom_fastq} ${hap_dad_fastq} merqury_result OMP_NUM_THREADS=$task.cpus
        """
    }
}