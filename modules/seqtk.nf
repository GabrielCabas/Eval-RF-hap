
process seqtk{
  input:
  path(hap)
  path(fastq)
  output:
  path("${hap.baseName}.fq.gz"), emit: fastq
  script:
  if (params.debug){
    """
    echo seqtk > ${hap.baseName}.fq.gz
    """
  }
  else{
    """
    seqtk subseq ${fastq} ${hap} | pigz -p $task.cpus  >  ${hap.baseName}.fq.gz
    """
  }
}

process merge {
    input:
    path hap_A_fastq
    path hap_B_fastq
    path hap_U_fastq
    output:
    path "hap_A_merged.fasta", emit: hap_A_merged
    path "hap_B_merged.fasta", emit: hap_B_merged
    script:
    if(params.debug){
    """
    echo "merged A + U" > hap_A_merged.fasta
    echo "merged B + U" > hap_B_merged.fasta
    """
    }
    else{
    """
    cat ${hap_A_fastq} ${hap_U_fastq} > hap_A_merged.fasta
    cat ${hap_B_fastq} ${hap_U_fastq} > hap_B_merged.fasta
    """
    }
}