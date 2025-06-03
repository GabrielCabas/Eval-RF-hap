process meryl{
    input:
    path reads
    val out_name
    output:
    path("${out_name}.count.meryl"), emit: counts_file
    script:
    if (params.debug){
        """
        echo "meryl --help" > ${out_name}.count.meryl
        """
    }
    else{
        """
        meryl threads=$task.cpus k=21 count $reads output ${out_name}.count.meryl
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