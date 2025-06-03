include { seqtk as seqtk_A;
          seqtk as seqtk_B 
} from "../modules/seqtk"
workflow seqtk {
    take:
    hap_A_ids
    hap_B_ids
    dad_short_reads
    mom_short_reads

    main:
    seqtk_A(hap_A_ids, mom_short_reads)
    seqtk_B(hap_B_ids, dad_short_reads)

    emit:
    hap_A_fastq = seqtk_A.out.fastq
    hap_B_fastq = seqtk_B.out.fastq
}