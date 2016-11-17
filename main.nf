#!/usr/bin/env nextflow

params.input = ""

params.output = ""

outputDir = file(params.output)

sraIds = Channel.create()

Channel
    .from(file(params.input))
    .splitCsv(sep:'\t', header: true)
    .map { it.Run_s }
    .into(sraIds)

process fetchSRA {

    errorStrategy 'retry'

    maxRetries 5

    maxErrors 50000

    tag { id + '_fastq_dump'}

    input:
    val id from sraIds

    output:
    val id  into fastqIds

    """
     ${params.SRA_TOOLKIT_DIR}/fastq-dump --readids --gzip --minReadLen ${params.READ_LENGTH} --split-files  ${id} -O ${outputDir}
    """
}

process seqPurge {

    errorStrategy 'retry'

    maxRetries 5

    maxErrors 50000

    cpus 1

    tag { fileId + '_seqPurge' }

    input:
    val fileId from fastqIds

    output:
    val fileId into result

    """
     ${params.SEQPURGE} -in1 '${outputDir}/${fileId}_1.fastq.gz' -in2 '${outputDir}/${fileId}_2.fastq.gz' -out1 '${outputDir}/${fileId}_1.seqpurge.fastq.gz' -out2 '${outputDir}/${fileId}_2.seqpurge.fastq.gz' -out3 '${outputDir}/${fileId}_3.seqpurge.fastq.gz' 
    """
}
