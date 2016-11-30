# Sra-download

This pipeline downloads SRA files from NCBI and removes adapter sequences from paired end data using [seqpurge](https://www.ncbi.nlm.nih.gov/pubmed/27161244).

# How to use the pipeline:

1. Install Nextflow https://www.nextflow.io/docs/latest/getstarted.html#installation

2. Run the pipeline with the following command below, it will use [pbelmann/sra-download](https://hub.docker.com/r/pbelmann/sra-download/) docker container.

~~~BASH
nextflow run  pbelmann/sra-download  --cache /path/to/cache --output /path/to/output --input /path/to/input.txt -with-docker -with-trace -with-timeline  pbelmann/sra-download
~~~

   where:
   
 * '/path/to/cache' is a directory for storing the downloaded .sra files
    
 * '/path/to/output' is a directory for storing the output data
       
 * '/path/to/input.txt' is a file downloaded from [SRA Run Selector](https://www.ncbi.nlm.nih.gov/Traces/study/)
          The column containing the SRA ids should have the name 'Run_s' 


**NOTE!:** 
 
 * You can use this pipeline without docker but then you will have to change the path to the sra toolkit and seqpurge in your [config](https://github.com/pbelmann/sra-download/blob/master/nextflow.config).
 
 * You can distribute the pipeline on a grid system by providing the [executor](https://www.nextflow.io/docs/latest/executor.html) in your config.
