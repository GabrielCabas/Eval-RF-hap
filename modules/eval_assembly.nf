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
process yak_count{
    input:
    tuple path(reads_R1), path(reads_R2)
    output:
    path("${reads_R1.baseName}.yak"), emit: yak_file
    script:
    if (params.debug){
        """
        echo "yak count -o ${reads_R1.baseName}.yak ${reads_R1} ${reads_R1}" > "${reads_R1.baseName}.yak"
        """
    }
    else{
        """
        yak count -o ${reads_R1.baseName}.yak ${reads_R1} ${reads_R1}
        """
    }
}
process yak_trioeval{
    publishDir "$params.outdir/yak/", mode: "copy"
    input:
    path(mom_yak)
    path(dad_yak)
    path(child_assembly)
    output:
    path("${child_assembly}_yak.eval.txt"), emit: result
    script:
    if (params.debug){
        """
        echo "yak trioeval -t 16  ${mom_yak} ${dad_yak} ${child_assembly} > ${child_assembly}_yak.eval.txt" > ${child_assembly}_yak.eval.txt
        """
    }
    else{
        """
        yak trioeval -t 16  ${mom_yak} ${dad_yak} ${child_assembly} > ${child_assembly}_yak.eval.txt
        """
    }
}