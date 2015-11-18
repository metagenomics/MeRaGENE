#!/usr/bin/env nextflow

params.vendor = "$baseDir/vendor"
params.search = ""
params.keywords = ""
params.help = ""


if( params.help ) { 
    usage = file("$baseDir/usage.txt")   
    print usage.text
    return 
}

hmmDir = file(params.input)
outputDir = file(params.output)
ncbiDB = file(params.ncbi)
genomeFaa = file(params.genome)

keywordsFile = ""
if(params.keywords){
	keywordsFile = file(params.keywords)
}

searchFile = ""
if(params.search){
	searchFile = file(params.search)
}

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
list = Channel.fromPath(genomeFaa).splitFasta(by:6000,file:true).collectFile();
list.spread(allHmm).into(fastaChunk)

process hmmFolderScan {

    cpus "${params.hmm_cpu}"

    memory '8 GB'
    cache false

    maxForks 6000 

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
    
params.num = 1
num = params.num

process uniqer {
    
    cache false

    input:
    file domtblout
    params.num
      
    output:
    file outputFasta into fastaFiles

    """
    $baseDir/scripts/uniquer.sh $num domtblout outputFasta
    """    
}

uniq_lines = Channel.create()
uniq_overview = Channel.create()
fastaFiles.filter({it -> java.nio.file.Files.size(it)!=0}).tap(uniq_overview).flatMap{ file -> file.readLines() }.into(uniq_lines)

process getFasta {

    executor 'local'

    cpus 2

    memory '1 GB'

    input:
    val contigLine from uniq_lines
    
    output:
    file 'uniq_out'
    
    shell:
    '''
    #!/bin/sh
    contig=`echo "!{contigLine} " | cut -d ' ' -f 4`
    grep  "$contig " !{genomeFaa} > uniq_header
    buffer=`cat uniq_header | cut -c 2-`
    contig=`echo $buffer | cut -d" " -f1`
    awk -v p="$buffer" 'BEGIN{ ORS=""; RS=">"; FS="\\n" } $1 == p { print ">" $0 }' !{genomeFaa}  > !{baseDir}/$contig.faa
    awk -v p="$buffer" 'BEGIN{ ORS=""; RS=">"; FS="\\n" } $1 == p { print ">" $0 }' !{genomeFaa}  > uniq_out
    '''  

}

uniq_seq = Channel.create()
uniq_seqHtml = Channel.create()
uniq_out.separate( uniq_seq, uniq_seqHtml ) { a -> [a, a] }

process blastSeqTxt {
    
    cpus 4
    memory '8 GB'
    
    input:
    file uniq_seq

    output:
    file blast_out
    
    script:
    order = "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore sallacc salltitles staxids sallseqid"
/*
 * blast all fasta sequences against the ncbi database. A special output format is used, to make the data usable for the next pipeline.
 */ 
    shell:
    '''
    #!/bin/sh
    contig=`grep ">" !{uniq_seq} | cut -d" " -f1 | cut -c 2-`
    !{params.blastp} -db !{ncbiDB} -outfmt '!{order}' -query "!{uniq_seq}" -out "!{baseDir}/$contig.txt" -num_threads !{params.blast_cpu}
    echo "$contig" > blast_out
    '''
}

blast_all = Channel.create()
blast_out
   .collectFile()
   .into(blast_all)

process blastSeqHtml {

    cpus 4
    memory '8 GB'

    input:
    file uniq_seqHtml

/*
 * blast all fasta sequences against the ncbi database. The output is html formated, to get it legible for people.
 */
    shell:
    '''
    #!/bin/sh
    contig=`grep ">" !{uniq_seqHtml} | cut -d" " -f1 | cut -c 2-`
    !{params.blastp} -db !{ncbiDB} -query "!{uniq_seqHtml}" -html -out "!{outputDir}/$contig.html" -num_threads !{params.blast_cpu} 
    '''

}

PYTHON="$baseDir/vendor/python/bin/python"

coverages = Channel.create()
coverages.bind(params.cov.split(',').collect{file(it)}.join(' '))

bam = Channel.from(params.bam)
sortedIndexedBam = bam.flatMap{ files  -> files.split(',')} 

process bamToCoverage {
   
   cpus 2

   memory '4 GB'

   input: 
   val bam from sortedIndexedBam

   output:
   file coverage into coverages
   
   when:
   bam != ''

   script:
   """
   #!/bin/sh
   $PYTHON scripts/bam_to_coverage.py ${params.sortedIndexedBam} > coverage
   """
}

coverageFiles = Channel.create()
coverages.toList().into(coverageFiles)

uniq_overview = uniq_overview.collectFile()
process createOverview {
   
   cpus 2

   memory '4 GB'

   input:
   file blast_all 
   file uniq_overview 
   val coverageFiles

   output:
   val outputDir + '/overview.txt' into over

   shell:
   '''
   #!/bin/sh
   searchParam=""
   if [ -n !{params.search} ]
   then
       searchParam="--search=!{searchFile}"
   fi
   !{PYTHON} !{baseDir}/scripts/create_overview.py -u !{uniq_overview}  -faa !{baseDir} -o !{outputDir}  ${searchParam}  -c !{coverageFiles.join(' ')} 
   '''
}

process linkSearch {
   
   cpus 2

   memory '4 GB'

   input: 
   val x from over
   outputDir

   output:
   val outputDir into inputF 

   """
   #!/bin/sh
   $PYTHON $baseDir/scripts/link_search.py -o ${x} -out ${outputDir} 
   """
}


process folderToPubmed {
   
   executor 'local'
   
   cpus 2

   memory '4 GB'

   input:
   val inp from inputF
   outputDir

   output:
   val outputDir + '/all.pubHits'  into pub
   val outputDir + '/overview.txt' into over2

   shell:
   '''
   #!/bin/sh
   keywords=""
   if [ -f !{keywordsFile} ]
   then
         keywords=!{keywordsFile}
   else
         emptyKeywords="keywords.txt"
         touch $emptyKeywords 
         keywords=$emptyKeywords
   fi
   echo $keywords
   sh !{baseDir}/scripts/FolderToPubmed.sh !{inp} !{outputDir}  !{baseDir}/scripts/UrltoPubmedID.sh  ${keywords} 
   '''
}


process linkAssignment {
 
   cpus 2
 
   memory '6 GB'

   input:
   val x from over2
   val p from pub

   output:
   val outputDir + '/overview_new.txt' into overNew

   """
   #!/bin/sh
   $PYTHON $baseDir/scripts/link_assignment.py -o ${x} -pub ${p} 
   """
}

process buildHtml {

    cpus 2

    memory '3 GB'

    input:
    val overview from overNew

    """
    #!/bin/sh
    $PYTHON $baseDir/scripts/web/controller.py -o ${overview} -out ${outputDir} -conf $baseDir/scripts/web/config.yaml -templates $baseDir/scripts/web/app/templates
    """

}
