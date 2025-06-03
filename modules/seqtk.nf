
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