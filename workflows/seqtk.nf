include { seqtk as seqtk_mom;
          seqtk as seqtk_dad;
          seqtk as seqtk_unknown;
          merge as merge_mom;
          merge as merge_dad
} from "../modules/seqtk"
workflow seqtk {
    take:
    hap_mom_ids
    hap_dad_ids
    hap_unknown_ids
    child_long_reads

    main:
    seqtk_mom(hap_mom_ids, child_long_reads)
    seqtk_dad(hap_dad_ids, child_long_reads)
    seqtk_unknown(hap_unknown_ids, child_long_reads)
    merge_mom(seqtk_mom.out.fastq, seqtk_unknown.out.fastq)
    merge_dad(seqtk_dad.out.fastq, seqtk_unknown.out.fastq)

    emit:
    hap_mom_fastq = merge_mom.out.hap_merged
    hap_dad_fastq = merge_dad.out.hap_merged
}