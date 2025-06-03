include {merqury} from "../modules/eval_assembly.nf"

workflow eval_assembly{
    take:
    hapmers
    meryl_child_lr
    hap_A_fastq
    hap_B_fastq

    main:
    merqury(hapmers, meryl_child_lr, hap_A_fastq, hap_B_fastq)

    emit:
    merqury.out.result
}