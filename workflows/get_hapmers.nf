include { meryl as count_kmers_dad;
      meryl as count_kmers_mom;
      meryl as count_kmers_child_sr;
      meryl as count_kmers_child_lr;
      hapmers
} from '../modules/get_hapmers'

workflow count_kmers {
  take:
  dad_short_reads
  mom_short_reads
  child_short_reads
  child_long_reads

  main:
  count_kmers_dad(dad_short_reads, 24, "dad")
  count_kmers_mom(mom_short_reads, 24, "mom")
  count_kmers_child_sr(child_short_reads, 24, "child_sr")
  count_kmers_child_lr(child_long_reads, 24, "child_lr")

  emit:
  meryl_dad = count_kmers_dad.out.counts_file
  meryl_mom = count_kmers_mom.out.counts_file
  meryl_child_sr = count_kmers_child_sr.out.counts_file
  meryl_child_lr = count_kmers_child_lr.out.counts_file
}

workflow get_hapmers{
  take:
  meryl_dad
  meryl_mom
  meryl_child_sr

  main:
  hapmers(meryl_dad,
    meryl_mom,
    meryl_child_sr)
  
  emit:
  hapmers = hapmers.out.hap
}