include {merqury;
    yak_count as yak_count_mom;
    yak_count as yak_count_dad;
    yak_trioeval as yak_trioeval_mom;
    yak_trioeval as yak_trioeval_dad;
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