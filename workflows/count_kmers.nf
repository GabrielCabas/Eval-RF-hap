include { count_kmers as count_kmers_dad;
          count_kmers as count_kmers_mom;
          count_kmers as count_kmers_child
 } from '../modules/meryl'

workflow  count_kmers {
    take:
    dad_short_reads
    mom_short_reads
    child_short_reads

    main:
    count_kmers_dad(dad_short_reads, 24)
    count_kmers_mom(mom_short_reads, 24)
    count_kmers_child(child_short_reads, 24)

    emit:
    kmers_dad = count_kmers_dad.out.counts_file
    kmers_mom = count_kmers_mom.out.counts_file
    kmers_child = count_kmers_child.out.counts_file
}