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

process filter {

    errorStrategy 'retry'

    maxRetries 5

    maxErrors 50000

    tag { id + '_filter'}

    input:
    val id from sraIds

    output:
    stdout out into testedSraIds

    shell:
    '''
    #!/bin/bash
    READ_RUN=$(wget -qO- 'http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=!{id}&result=read_run' | tail -n +2)
    if [[ -z "$READ_RUN" ]]; then
         printf "not_found"
    else
         printf "!{id}"
    fi
    '''
}
   
filteredSraIds = Channel.create()
testedSraIds
   .filter({!it.equals("not_found")})
   .into(filteredSraIds)

process fetchSRA {

    errorStrategy 'retry'

    maxRetries 5

    maxErrors 50000

    tag { id + '_fastq_dump'}

    input:
    val id from filteredSraIds

    output:
    val id  into fastqIds

    """
     ${params.SRA_TOOLKIT_DIR}/fastq-dump --readids --gzip --minReadLen ${params.READ_LENGTH} --split-3  ${id} -O ${outputDir}
    """
}

existingFastqSraIds = Channel.create()
fastqIds
   .filter({file(params.output + "/" + it + "_?.fastq.gz", glob: true).size() == 2})
   .into(existingFastqSraIds)

process seqPurge {

    errorStrategy 'retry'

    maxRetries 5

    maxErrors 50000

    cpus 1

    tag { fileId + '_seqPurge' }

    input:
    val fileId from existingFastqSraIds

    output:
    val fileId into result

    """
     ${params.SEQPURGE} -in1 '${outputDir}/${fileId}_1.fastq.gz' -in2 '${outputDir}/${fileId}_2.fastq.gz' -out1 '${outputDir}/${fileId}_1.seqpurge.fastq.gz' -out2 '${outputDir}/${fileId}_2.seqpurge.fastq.gz' -out3 '${outputDir}/${fileId}_3.seqpurge' 
    """
}

result.subscribe { String fileId ->  file(fileId + "_?.fastq.gz").delete }
