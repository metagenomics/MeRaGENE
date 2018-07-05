#!/usr/bin/env nextflow

/*
vim: syntax=groovy
-*- mode: groovy;-*-
*/

/* Basic parameters. Parameters defined in the .config file will overide these */
params.vendor = "$baseDir/vendor"
params.search = ""
params.keywords = ""
params.help = ""
params.num = 1
params.input = "$baseDir/genome"
params.blast = 'blastn'
params.blast_cpu = 8
params.blast_db = "$baseDir/resFinder"
params.hmm = 'hmmsearch'
params.hmm_models = "$baseDir/hmms"
params.hmm_cpu = 8
params.outFolder = "$baseDir/out"
params.eValue = '1e-15'


/* If help flag is set, display the help file */
if( params.help ) { 
    usage = file("$baseDir/usage.txt")   
    print usage.text
    return 
}

/* Necessary parameters that have to be defined by the user */
hmmDir = file(params.input)
outputDir = file(params.output)
ncbiDB = file(params.ncbi)
genomeFaa = file(params.genome)

/* If keyword flag is set, load the file */
keywordsFile = ""
if(params.keywords){
	keywordsFile = file(params.keywords)
}

/* ??? */
searchFile = ""
if(params.search){
	searchFile = file(params.search)
}

/* Bootstrap process. If the output folder already exists, the pipeline is stopped, to prevent an accidental overwrite of data. 
 * If it doesn't exist, it will be created. The basefolders makefile is used to install a local (virtual) python version, with all dependencies  */
process bootstrap {

   executor 'local'

   input:
   params.vendor
   
   output:
   file allHmm

   shell:
   if(outputDir.exists()) 
      exit(0, "Directory ${outputDir} already exists. Please remove it or assign another output directory.")
   else
      outputDir.mkdir()
      """
      #!/bin/bash
      if [ ! -d !{params.vendor} ]
      then
          make -C !{baseDir} install 
      fi
      cat !{hmmDir}/*.hmm > allHmm
      ${params.hmm_press} allHmm
      """
}

fastaChunk = Channel.create()
/* Channel created from given path. Split in chunks of 6000 sequences per chunk. By default chunks are kept in memory.
 * Here "file: true" is used to save the chunks into files in order to not incur in a OutOfMemoryException. 
 * CollectFile ist used to get these files into the channel. Be aware that all these happens in the local storage. 
 * It will require as much free space as are the data you are collecting. 
 */
list = Channel.fromPath(genomeFaa).splitFasta(by:1,file:true).collectFile(); /*!!splitFasta wieder hochsetzen!!*/
list.spread(allHmm).into(fastaChunk)


process hmmFolderSearch {

    publishDir "$baseDir/output", mode: 'copy', overwrite: false

    cpus "${params.hmm_cpu}"

    memory '8 GB'

    input:
    val chunk from fastaChunk

    output:
    file domtblout

    script:
    fastaChunkFile = chunk[0]
    hmm = chunk[1]
    """
    #!/bin/sh
    ${params.hmm_scan} -E ${params.hmm_evalue} --domtblout domtblout --cpu ${params.hmm_cpu} -o allOut ${hmm} ${fastaChunkFile}
    """
}


num = params.num

process uniqer {

    publishDir "$baseDir/output", mode: 'copy', overwrite: false
    echo true

    when:
    domtblout.isEmpty()

    input:
    file domtblout
    params.num
      
    output:
    file outputFasta into fastaFiles

    """
    $baseDir/scripts/uniquer.sh $num domtblout outputFasta
    echo "Gelaufen ${domtblout.isEmpty()}"
    """    
}


process test {

	echo true

  	script:
  	"echo Hello"
}

