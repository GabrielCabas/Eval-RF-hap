include { count_kmers; get_hapmers } from './workflows/get_hapmers'
include { assemble } from './workflows/assemble'
include { eval_assembly_merqury; eval_assembly_yak} from './workflows/eval_assembly'

workflow  {
    dad_sr = Channel.value(tuple file(params.dad_short_reads_R1), file(params.dad_short_reads_R2))
    mom_sr = Channel.value(tuple file(params.mom_short_reads_R1), file(params.mom_short_reads_R2))
    child_sr = Channel.value(tuple file(params.child_short_reads_R1), file(params.child_short_reads_R2))
    child_lr = Channel.value(file(params.child_long_reads))
    
    hap_mom_ids = Channel.value(file(params.hap_mom_ids))
    hap_dad_ids = Channel.value(file(params.hap_dad_ids))
    hap_unknown_ids = Channel.value(file(params.hap_unknown_ids))
    
    assemble(hap_mom_ids, hap_dad_ids, hap_unknown_ids, child_lr)
    if (params.tool == "merqury" || params.tool == "both"){
        count_kmers(dad_sr, mom_sr, child_sr)

        get_hapmers(count_kmers.out.meryl_dad,
            count_kmers.out.meryl_mom,
            count_kmers.out.meryl_child_sr)

        eval_assembly_merqury(get_hapmers.out.hapmers, count_kmers.out.meryl_child_sr,
            assemble.out.hap_mom_fasta, assemble.out.hap_dad_fasta)

        eval_assembly_merqury.out.view()
    }
    if (params.tool == "yak" || params.tool == "both"){
        eval_assembly_yak(mom_sr, dad_sr,
            assemble.out.hap_mom_fasta, assemble.out.hap_dad_fasta)
        eval_assembly_yak.out.result_dad.view()
        eval_assembly_yak.out.result_mom.view()
    }
}