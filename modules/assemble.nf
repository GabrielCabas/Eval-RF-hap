
process seqtk{
  input:
  path(hap)
  path(fastq)
  output:
  path("${hap.baseName}.fq.gz"), emit: fastq
  script:
  """
  seqtk subseq ${fastq} ${hap} | pigz -p $task.cpus  >  ${hap.baseName}.fq.gz
  """
  stub:
  """
  echo seqtk > ${hap.baseName}.fq.gz
  """
}

process hifiasm {
  publishDir "$params.outdir/hifiasm/", mode: "copy"
  input:
  path hap_i_fastq
  path hap_U_fastq
  output:
  path "${hap_i_fastq.baseName}_merged.fasta", emit: hap_merged
  path "${hap_i_fastq.baseName}_merged*.gfa", emit: hap_gfa
  path "${hap_i_fastq.baseName}_merged*.bed", emit: hap_bed
  path "${hap_i_fastq.baseName}_merged*.ont.bp.p_ctg.noseq.gfa", emit: hap_noseq_gfa
  script:
  """
  hifiasm -o ${hap_i_fastq.baseName}_merged.ont -l 3 --ont ${hap_i_fastq} ${hap_U_fastq} -t $task.cpus
  gfatools gfa2fa ${hap_i_fastq.baseName}_merged.ont.bp.p_ctg.gfa > ${hap_i_fastq.baseName}_merged.fasta
  """
  stub:
  """
  echo "merged ${hap_i_fastq.baseName} + U" > "${hap_i_fastq.baseName}_merged.fasta"
  echo "merged ${hap_i_fastq.baseName} + U" > "${hap_i_fastq.baseName}_merged.gfa"
  echo "merged ${hap_i_fastq.baseName} + U" > "${hap_i_fastq.baseName}_merged.bed"
  echo "merged ${hap_i_fastq.baseName} + U" > "${hap_i_fastq.baseName}_merged.ont.bp.p_ctg.noseq.gfa"
  """
}
