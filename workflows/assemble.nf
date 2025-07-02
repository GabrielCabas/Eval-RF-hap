include { seqtk as seqtk_mom;
          seqtk as seqtk_dad;
          seqtk as seqtk_unknown;
          hifiasm as hifiasm_mom;
          hifiasm as hifiasm_dad
} from "../modules/assemble"
workflow assemble {
    take:
    hap_mom_ids
    hap_dad_ids
    hap_unknown_ids
    child_long_reads

    main:
    seqtk_mom(hap_mom_ids, child_long_reads)
    seqtk_dad(hap_dad_ids, child_long_reads)
    seqtk_unknown(hap_unknown_ids, child_long_reads)
    hifiasm_mom(seqtk_mom.out.fastq, seqtk_unknown.out.fastq)
    hifiasm_dad(seqtk_dad.out.fastq, seqtk_unknown.out.fastq)

    emit:
    hap_mom_fasta = hifiasm_mom.out.hap_merged
    hap_dad_fasta = hifiasm_dad.out.hap_merged
}