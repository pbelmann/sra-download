#!/usr/bin/env nextflow

params.input = ""

params.output = "/home/belmann/projects/multi-frhit"

outputDir = file(params.output)

params.logFile = params.output + "/sra_download_log.txt"

logFile = file(params.logFile)

sraIds = Channel.create()

log1 = Channel.create().subscribe { logFile << "fastq-dump for $it finished \n" }

log2 = Channel.create().subscribe { logFile << "seqPurge for $it finished \n" }

Channel
    .from(file(params.input))
    .splitCsv(sep:'\t', header: true)
    .map { it.Run_s }
    .into(sraIds)

process fetchSRA {

    errorStrategy 'retry'

    maxRetries 5

    maxErrors 50000

    cpus 1

    memory '2 GB'

    tag { id + '_fastq_dump'}

    input:
    val id from sraIds

    output:
    val id  into fastqIds

    """
     ${params.SRA_TOOLKIT_DIR}/fastq-dump --readids --gzip --minReadLen ${params.READ_LENGTH} --split-files  ${id} -O ${outputDir}
    """
}

fastqIds = fastqIds.tap(log1)

process seqPurge {

    errorStrategy 'retry'

    maxRetries 5

    maxErrors 50000

    cpus 1

    memory '2 GB'

    tag { fileId + '_seqPurge' }

    input:
    val fileId from fastqIds

    output:
    val fileId into result

    """
     ${params.SEQPURGE} -in1 '${outputDir}/${fileId}_1.fastq.gz' -in2 '${outputDir}/${fileId}_2.fastq.gz' -out1 '${outputDir}/${fileId}_1.seqpurge.fastq.gz' -out2 '${outputDir}/${fileId}_2.seqpurge.fastq.gz' -out3 '${outputDir}/${fileId}_3.seqpurge.fastq.gz' 
    """
}

result = result.tap(log2)
