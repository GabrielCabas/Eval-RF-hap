include {merqury} from "../modules/eval_assembly.nf"

workflow eval_assembly{
    take:
    hapmers
    meryl_child_lr
    hap_mom_fastq
    hap_dad_fastq

    main:
    merqury(hapmers, meryl_child_lr, hap_mom_fastq, hap_dad_fastq)

    emit:
    result = merqury.out.result
}