include { seqtk as seqtk_A;
          seqtk as seqtk_B;
          seqtk as seqtk_U;
          merge
} from "../modules/seqtk"
workflow seqtk {
    take:
    hap_A_ids
    hap_B_ids
    hap_U_ids
    dad_short_reads
    mom_short_reads
    child_long_reads

    main:
    seqtk_A(hap_A_ids, mom_short_reads)
    seqtk_B(hap_B_ids, dad_short_reads)
    seqtk_U(hap_U_ids, child_long_reads)
    merge(seqtk_A.out.fastq, seqtk_B.out.fastq, seqtk_U.out.fastq)

    emit:
    hap_A_fastq = merge.out.hap_A_merged
    hap_B_fastq = merge.out.hap_B_merged
}