include {merqury;
    yak_count as yak_count_mom;
    yak_count as yak_count_dad;
    yak_trioeval as yak_trioeval_mom;
    yak_trioeval as yak_trioeval_dad;
    gfastats;
    extract_table_full;
    extract_table_merqury;
    extract_table_yak;
    } from "../modules/eval_assembly.nf"

workflow eval_assembly_merqury{
    take:
    hapmers
    meryl_child_sr
    hap_mom_fasta
    hap_dad_fasta

    main:
    merqury(hapmers, meryl_child_sr, hap_mom_fasta, hap_dad_fasta)

    emit:
    result = merqury.out.result
    phased_stats_hapA = merqury.out.phased_stats_hapA
    phased_stats_hapB = merqury.out.phased_stats_hapB
}

workflow eval_assembly_yak{
    take:
    mom_fastq
    dad_fastq
    hap_mom_fasta
    hap_dad_fasta
    
    main:
    yak_count_mom(mom_fastq)
    yak_count_dad(dad_fastq)
    yak_trioeval_mom(yak_count_mom.out.yak_file,
        yak_count_dad.out.yak_file,
        hap_mom_fasta
        )
    yak_trioeval_dad(yak_count_mom.out.yak_file,
        yak_count_dad.out.yak_file,
        hap_dad_fasta
        )
    emit:
    result_mom = yak_trioeval_mom.out.result
    result_dad = yak_trioeval_dad.out.result
}


workflow eval_assembly_yak_premade{
    take:
    mom_yak
    dad_yak
    hap_mom_fasta
    hap_dad_fasta
    
    main:
    yak_trioeval_mom(mom_yak,
        dad_yak,
        hap_mom_fasta
        )
    yak_trioeval_dad(mom_yak,
        dad_yak,
        hap_dad_fasta
        )
    emit:
    result_mom = yak_trioeval_mom.out.result
    result_dad = yak_trioeval_dad.out.result
}

workflow eval_gfastats{
    take:
    gfastats_noseq_hapA
    gfastats_noseq_hapB

    main:
    gfastats(gfastats_noseq_hapA, gfastats_noseq_hapB)
    
    emit:
    gfastats_mom = gfastats.out.hapA_gfastats
    gfastats_dad = gfastats.out.hapB_gfastats
}

workflow build_table {
    take:
    hapA_gfastats
    hapB_gfastats
    phased_stats_hapA
    phased_stats_hapB
    method
    dataset
    yak_result_hapA
    yak_result_hapB

    main:
    if (params.tool == "both") {
        extract_table_full(
            hapA_gfastats, hapB_gfastats,
            phased_stats_hapA, phased_stats_hapB,
            method, dataset, yak_result_hapA, yak_result_hapB
        )
        table = extract_table_full.out.final_table
    }
    else if (params.tool == "merqury") {
        extract_table_merqury(
            hapA_gfastats, hapB_gfastats,
            phased_stats_hapA, phased_stats_hapB,
            method, dataset
        )
        table = extract_table_merqury.out.final_table
    }
    else if (params.tool == "yak") {
        extract_table_yak(
            hapA_gfastats, hapB_gfastats,
            method, dataset, yak_result_hapA, yak_result_hapB
        )
        table = extract_table_yak.out.final_table
    }
    else {
        table = null
    }

    emit:
    table = table
}