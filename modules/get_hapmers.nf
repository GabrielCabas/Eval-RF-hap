process meryl_sr{
    input:
    tuple path(reads_R1), path(reads_R2)
    output:
    path("${reads_R1.baseName}.count.meryl"), emit: counts_file
    script:
    if (params.debug){
        """
        echo "meryl --help" > ${reads_R1.baseName}.count.meryl
        """
    }
    else{
        """
        meryl threads=$task.cpus k=21 count $reads_R1 $reads_R2 output ${reads_R1.baseName}.count.meryl
        """
    }
}

process meryl_lr{
    input:
    path(reads)
    output:
    path("${reads.baseName}.count.meryl"), emit: counts_file
    script:
    if (params.debug){
        """
        echo "meryl --help" > ${reads.baseName}.count.meryl
        """
    }
    else{
        """
        meryl threads=$task.cpus k=21 count $reads output ${reads.baseName}.count.meryl
        """
    }
}

process hapmers{
    input:
    path dad_counts
    path mom_counts
    path child_counts
    output:
    tuple path("hapA.only.meryl"), path("hapB.only.meryl"), path("shrd.meryl"), emit: hap
    script:
    if (params.debug){
        """
        echo "hapmers --help" > hapA.only.meryl
        echo "hapmers --help" > hapB.only.meryl
        echo "hapmers --help" > shrd.meryl
        """
    }
    else{
        """
        sh \$MERQURY/trio/hapmers.sh  hapA.only.meryl hapB.only.meryl shrd.meryl
        """
    }
}