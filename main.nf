include { count_kmers; get_hapmers } from './workflows/get_hapmers'
include { seqtk } from './workflows/seqtk'
include { eval_assembly } from './workflows/eval_assembly'

workflow  {
    dad_sr = Channel.value(tuple file(params.dad_short_reads_R1), file(params.dad_short_reads_R2))
    mom_sr = Channel.value(tuple file(params.mom_short_reads_R1), file(params.mom_short_reads_R2))
    child_sr = Channel.value(tuple file(params.child_short_reads_R1), file(params.child_short_reads_R2))
    child_lr = Channel.value(file(params.child_long_reads))
    
    hap_mom_ids = Channel.value(file(params.hap_mom_ids))
    hap_dad_ids = Channel.value(file(params.hap_dad_ids))
    hap_unknown_ids = Channel.value(file(params.hap_unknown_ids))

    seqtk(hap_mom_ids, hap_dad_ids, hap_unknown_ids, child_lr)

    count_kmers(dad_sr, mom_sr, child_sr, child_lr)

    get_hapmers(count_kmers.out.meryl_dad,
        count_kmers.out.meryl_mom,
        count_kmers.out.meryl_child_sr)

    eval_assembly(get_hapmers.out.hapmers, count_kmers.out.meryl_child_lr,
        seqtk.out.hap_mom_fastq, seqtk.out.hap_dad_fastq)

    eval_assembly.out.view()
}