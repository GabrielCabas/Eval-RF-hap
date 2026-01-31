process merqury{
    publishDir "$params.outdir/merqury/", mode: "copy"
    input:
    tuple path(hapmers_dad), path(hapmers_mom)
    path(meryl_child_sr)
    path(hap_mom_fastq)
    path(hap_dad_fastq)
    output:
    path("merqury_result*"), emit: result
    path("merqury_result.${hap_mom_fastq.baseName}.100_20000.phased_block.stats"), emit : phased_stats_hapA
    path("merqury_result.${hap_dad_fastq.baseName}.100_20000.phased_block.stats"), emit : phased_stats_hapB
    script:
    """
    export MERQURY=/opt/conda/share/merqury
    \$MERQURY/merqury.sh ${meryl_child_sr} ${hapmers_mom} ${hapmers_dad} ${hap_mom_fastq} ${hap_dad_fastq} merqury_result OMP_NUM_THREADS=$task.cpus
    """
    stub:
    """
    echo "merqury_result	1	1	1	1	1	1	1	1	0.1%" > merqury_result.${hap_mom_fastq.baseName}.100_20000.phased_block.stats
    echo "merqury_result	1	1	1	1	1	1	1	1	0.1%" > merqury_result.${hap_dad_fastq.baseName}.100_20000.phased_block.stats
    touch merqury_result.stub
    """
}
process yak_count{
    input:
    tuple path(reads_R1), path(reads_R2)
    output:
    path("${reads_R1.baseName}.yak"), emit: yak_file
    script:
    """
    yak count -o ${reads_R1.baseName}.yak ${reads_R1} ${reads_R1}
    """
    stub:
    """
    echo "yak count stub" > "${reads_R1.baseName}.yak"
    """
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
    """
    yak trioeval -t $task.cpus  ${mom_yak} ${dad_yak} ${child_assembly} > ${child_assembly}_yak.eval.txt
    """
    stub:
    """
    echo "yak trioeval stub" > ${child_assembly}_yak.eval.txt
    """
}

process gfastats{
    
    publishDir "$params.outdir/gfastats/", mode: "copy"
    
    input:
    path(gfastats_noseq_hapA)
    path(gfastats_noseq_hapB)

    output:
    path("hapA.gfastats") , emit : hapA_gfastats
    path("hapB.gfastats") , emit : hapB_gfastats
    

    script:
    """
    gfastats --discover-paths ${gfastats_noseq_hapA} >  hapA.gfastats
    gfastats --discover-paths ${gfastats_noseq_hapB} >  hapB.gfastats
    """
    stub:
    """
    echo "gfastats stub" > hapA.gfastats
    echo "gfastats stub" > hapB.gfastats
    """
}

process extract_table_merqury{
    publishDir "$params.outdir/table/", mode: "copy"

    input:
    path(hapA_gfastats)
    path(hapB_gfastats)
    path(phased_stats_hapA)
    path(phased_stats_hapB)
    val(method)
    val(dataset)

    output:
    path("phasing_stats.tsv"), emit : final_table

    script:
    """
    n50_gfastats_hapA=\$(grep "Scaffold N50" ${hapA_gfastats}  | awk 'BEGIN{FS=": "}{print \$2}')
    n50_gfastats_hapB=\$(grep "Scaffold N50" ${hapB_gfastats}  | awk 'BEGIN{FS=": "}{print \$2}')

    n50_merqury_hapA=\$(awk 'BEGIN{FS="\t"}{print \$6}' ${phased_stats_hapA})
    n50_merqury_hapB=\$(awk 'BEGIN{FS="\t"}{print \$6}' ${phased_stats_hapB})

    avg_block_size_hapA=\$(awk 'BEGIN{FS="\t"}{print \$5}' ${phased_stats_hapA})
    avg_block_size_hapB=\$(awk 'BEGIN{FS="\t"}{print \$5}' ${phased_stats_hapB})

    switch_error_merqury_hapA=\$(awk 'BEGIN{FS="\t"}{NF>1 ; print \$10}' ${phased_stats_hapA})
    switch_error_merqury_hapB=\$(awk 'BEGIN{FS="\t"}{NF>1 ; print \$10}' ${phased_stats_hapB})

    echo "Assembly\tN50gfastats\tN50merqury\tSwitchErrorMerqury\tAvgBlockSize\tMethod\tDataset" >  phasing_stats.tsv 
    echo "Maternal\t\${n50_gfastats_hapA}\t\${n50_merqury_hapA}\t\${switch_error_merqury_hapA}\t\${avg_block_size_hapA}\t${method}\t${dataset}" >> phasing_stats.tsv
    echo "Paternal\t\${n50_gfastats_hapB}\t\${n50_merqury_hapB}\t\${switch_error_merqury_hapB}\t\${avg_block_size_hapB}\t${method}\t${dataset}" >> phasing_stats.tsv
    """
    stub:
    """
    echo "Assembly\tN50gfastats\tN50merqury\tSwitchErrorMerqury\tAvgBlockSize\tMethod\tDataset" > phasing_stats.tsv
    echo "Maternal\t1\t1\t0.1%\t1\t${method}\t${dataset}" >> phasing_stats.tsv
    echo "Paternal\t1\t1\t0.1%\t1\t${method}\t${dataset}" >> phasing_stats.tsv
    """
}

process extract_table_yak{
    publishDir "$params.outdir/table/", mode: "copy"

    input:
    path(hapA_gfastats)
    path(hapB_gfastats)
    val(method)
    val(dataset)
    path(yak_result_hapA)
    path(yak_result_hapB)

    output:
    path("phasing_stats.tsv"), emit : final_table

    script:
    """
    n50_gfastats_hapA=\$(grep "Scaffold N50" ${hapA_gfastats}  | awk 'BEGIN{FS=": "}{print \$2}')
    n50_gfastats_hapB=\$(grep "Scaffold N50" ${hapB_gfastats}  | awk 'BEGIN{FS=": "}{print \$2}')

    switch_error_yak_hapA=\$(tail ${yak_result_hapA} | grep "W" | awk 'BEGIN{FS="\t"}{print \$4}')
    switch_error_yak_hapB=\$(tail ${yak_result_hapB} | grep "W" | awk 'BEGIN{FS="\t"}{print \$4}')

    echo "Assembly\tN50gfastats\tSwitchErrorYak\tMethod\tDataset" >  phasing_stats.tsv 
    echo "Maternal\t\${n50_gfastats_hapA}\t\${switch_error_yak_hapA}\t${method}\t${dataset}" >> phasing_stats.tsv
    echo "Paternal\t\${n50_gfastats_hapB}\t\${switch_error_yak_hapB}\t${method}\t${dataset}" >> phasing_stats.tsv
    """
    stub:
    """
    echo "Assembly\tN50gfastats\tSwitchErrorYak\tMethod\tDataset" > phasing_stats.tsv
    echo "Maternal\t1\t0.01\t${method}\t${dataset}" >> phasing_stats.tsv
    echo "Paternal\t1\t0.01\t${method}\t${dataset}" >> phasing_stats.tsv
    """
}
process extract_table_full{
    publishDir "$params.outdir/table/", mode: "copy"

    input:
    path(hapA_gfastats)
    path(hapB_gfastats)
    path(phased_stats_hapA)
    path(phased_stats_hapB)
    val(method)
    val(dataset)
    path(yak_result_hapA)
    path(yak_result_hapB)

    output:
    path("phasing_stats.tsv"), emit : final_table

    script:
    """
    n50_gfastats_hapA=\$(grep "Scaffold N50" ${hapA_gfastats}  | awk 'BEGIN{FS=": "}{print \$2}')
    n50_gfastats_hapB=\$(grep "Scaffold N50" ${hapB_gfastats}  | awk 'BEGIN{FS=": "}{print \$2}')

    n50_merqury_hapA=\$(awk 'BEGIN{FS="\t"}{print \$6}' ${phased_stats_hapA})
    n50_merqury_hapB=\$(awk 'BEGIN{FS="\t"}{print \$6}' ${phased_stats_hapB})

    avg_block_size_hapA=\$(awk 'BEGIN{FS="\t"}{print \$5}' ${phased_stats_hapA})
    avg_block_size_hapB=\$(awk 'BEGIN{FS="\t"}{print \$5}' ${phased_stats_hapB})

    switch_error_merqury_hapA=\$(awk 'BEGIN{FS="\t"}{NF>1 ; print \$10}' ${phased_stats_hapA})
    switch_error_merqury_hapB=\$(awk 'BEGIN{FS="\t"}{NF>1 ; print \$10}' ${phased_stats_hapB})

    switch_error_yak_hapA=\$(tail ${yak_result_hapA} | grep "W" | awk 'BEGIN{FS="\t"}{print \$4}')
    switch_error_yak_hapB=\$(tail ${yak_result_hapB} | grep "W" | awk 'BEGIN{FS="\t"}{print \$4}')

    echo "Assembly\tN50gfastats\tN50merqury\tSwitchErrorMerqury\tSwitchErrorYak\tAvgBlockSize\tMethod\tDataset" >  phasing_stats.tsv 
    echo "Maternal\t\${n50_gfastats_hapA}\t\${n50_merqury_hapA}\t\${switch_error_merqury_hapA}\t\${switch_error_yak_hapA}\t\${avg_block_size_hapA}\t${method}\t${dataset}" >> phasing_stats.tsv
    echo "Paternal\t\${n50_gfastats_hapB}\t\${n50_merqury_hapB}\t\${switch_error_merqury_hapB}\t\${switch_error_yak_hapB}\t\${avg_block_size_hapB}\t${method}\t${dataset}" >> phasing_stats.tsv
    """
    stub:
    """
    echo "Assembly\tN50gfastats\tN50merqury\tSwitchErrorMerqury\tSwitchErrorYak\tAvgBlockSize\tMethod\tDataset" > phasing_stats.tsv
    echo "Maternal\t1\t1\t0.1%\t0.01\t1\t${method}\t${dataset}" >> phasing_stats.tsv
    echo "Paternal\t1\t1\t0.1%\t0.01\t1\t${method}\t${dataset}" >> phasing_stats.tsv
    """
}