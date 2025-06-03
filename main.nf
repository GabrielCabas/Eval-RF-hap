include { get_hapmers } from './workflows/get_hapmers'
include { seqtk } from './workflows/seqtk'

workflow  {
    dad_sr = Channel.value(file(params.dad_short_reads))
    mom_sr = Channel.value(file(params.mom_short_reads))
    child_sr = Channel.value(file(params.child_short_reads))
    child_lr = Channel.value(file(params.child_long_reads))
    hap_A_ids = Channel.value(file(params.hap_A_ids))
    hap_B_ids = Channel.value(file(params.hap_B_ids))
    
    seqtk(hap_A_ids, hap_B_ids, dad_sr, mom_sr)
    get_hapmers(dad_sr, mom_sr, child_sr)

}