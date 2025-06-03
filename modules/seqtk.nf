
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
    path hap_i_fastq
    path hap_U_fastq
    output:
    path "${hap_i_fastq.baseName}_merged.fasta", emit: hap_merged
    script:
    if(params.debug){
    """
    echo "merged ${hap_i_fastq.baseName} + U" > "${hap_i_fastq.baseName}_merged.fasta"
    """
    }
    else{
    """
    cat ${hap_i_fastq} ${hap_U_fastq} > "${hap_i_fastq.baseName}_merged.fasta"
    """
    }
}