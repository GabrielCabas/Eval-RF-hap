process count_kmers{
    input:
        path reads
        val k
    output:
        path("count.meryl"), emit: counts_file
    script:
    if (params.debug){
        """
        echo "meryl --help" > count.meryl
        """
    }
    else{
        """
        meryl threads=$task.cpus k=$k count $reads output count.meryl
        """
    }
}
