include { count_kmers } from './workflows/count_kmers'
workflow  {
    dad_sr = Channel.value(file(params.dad_short_reads))
    mom_sr = Channel.value(file(params.mom_short_reads))
    child_sr = Channel.value(file(params.child_short_reads))
    
    count_kmers(dad_sr, mom_sr, child_sr)
}