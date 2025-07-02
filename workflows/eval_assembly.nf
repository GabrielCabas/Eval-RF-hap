include {merqury} from "../modules/eval_assembly.nf"

workflow eval_assembly{
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