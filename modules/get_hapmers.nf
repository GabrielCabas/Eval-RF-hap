process meryl_sr{
    input:
    tuple path(reads_R1), path(reads_R2)
    output:
    path("${reads_R1.baseName}.count.meryl"), emit: counts_file
    script:
    def memory = task.memory.toGiga()
    """
    meryl threads=$task.cpus k=21 memory=${memory} count $reads_R1 $reads_R2 output ${reads_R1.baseName}.count.meryl
    """
    stub:
    """
    echo "meryl --help" > ${reads_R1.baseName}.count.meryl
    """
}

process meryl_lr{
    input:
    path(reads)
    output:
    path("${reads.baseName}.count.meryl"), emit: counts_file
    script:
    def memory = task.memory.toGiga()
    """
    meryl threads=$task.cpus memory=${memory} k=21 count $reads output ${reads.baseName}.count.meryl
    """
    stub:
    """
    echo "meryl --help" > ${reads.baseName}.count.meryl
    """
}

process hapmers{
    input:
    path dad_counts
    path mom_counts
    path child_counts
    output:
    tuple path("${mom_counts.baseName}.hapmer.meryl"), path("${dad_counts.baseName}.hapmer.meryl"), emit: hap
    script:
    """
    export MERQURY=/opt/conda/share/merqury
    \$MERQURY/trio/hapmers.sh ${mom_counts} ${dad_counts} ${child_counts}
    """
    stub:
    """
    echo "hapmers --help" > ${mom_counts.baseName}.hapmer.meryl
    echo "hapmers --help" > ${dad_counts.baseName}.hapmer.meryl
    """
}