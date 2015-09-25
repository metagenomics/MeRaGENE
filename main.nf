#!/usr/bin/env nextflow

params.vendor = "$baseDir/vendor"

process bootstrap {

   executor 'local'

   input:
   params.vendor
   
   output:
   val 'start' into bootstrap

   script:
   outputDir = file(params.OUTPUT)
   if(outputDir.exists()) 
      error "Directory ${params.OUTPUT} already exists. Please remove it or assign another output directory." 
   else
      outputDir.mkdir()
      """
      #!/bin/bash
      if [ ! -d ${params.vendor} ]
      then
          make -C ${baseDir} install 
      fi
      """
}


process hmmFolderScan {

    cpus "${params.HMM_CPU}"

    memory '8 GB'
    cache false

    input:
    val start from bootstrap
    file hmmInput from '${params.INPUT}'   

    output:
    file domtblout
    file allOut
    file outputFasta 

    """
    #!/bin/sh
    # All HMM files inside the input folder are merged to one big HMM file inside the output folder.
    cat ${params.INPUT}/*.hmm > allHmm

    # New HMM Databse needs to be indexed and precomputed for HMMScan to work.
    ${params.HMM_PRESS} allHmm

    #HMMScan qsub grid call.
    ${params.HMM_SCAN} -E ${params.HMM_EVALUE} --domtblout domtblout --cpu ${params.HMM_CPU} -o allOut allHmm ${params.GENOME}
    touch outputFasta
    """
}

params.num = 1
num = params.num

process uniqer {
    
    cache false

    input:
    file domtblout
    file outputFasta
    params.num
      
    output:
    file outputFasta into fastaFiles

    """
    $baseDir/scripts/uniquer.sh $num domtblout outputFasta
    """    
}

uniq_lines = Channel.create()
uniq_overview = Channel.create()
fastaFiles.separate( fastaFiles, uniq_overview ) { a -> [a, a] }
fastaFiles.flatMap{ file -> file.readLines() }.into(uniq_lines)

/* end = Channel.create()
   fastaFiles.subscribe onComplete: { end.bind("start") }
   end.subscribe{print it} */

process getFastaHeader {

    cpus 2

    memory '1 GB'

    input:
    val contigLine from uniq_lines
    
    output:
    file 'uniq_header'
    
    shell:
    '''
    #!/bin/sh
    contig=`echo "!{contigLine} " | cut -d ' ' -f 4`
    grep  "$contig " !{params.GENOME} > uniq_header
    '''  

}

process getContigSeq {
    
    cpus 2
    memory '1 GB'
    
    input:
    params.GENOME
    file uniq_header
    
    output:
    file 'uniq_out'
    
/*
 * The fasta headers of the previous process is used, to find and extract the whole fasta sequence.
 * This is done three times. Once to save the sequence in an file for further use. The second and third time,
 * to pipe them into two channels to be used by the next processes. 
 */
    shell:
    '''
    #!/bin/sh
    buffer=`cat uniq_header | cut -c 2-`
    contig=`echo $buffer | cut -d" " -f1`
    awk -v p="$buffer" 'BEGIN{ ORS=""; RS=">"; FS="\\n" } $1 == p { print ">" $0 }' !{params.GENOME}  > !{baseDir}/$contig.faa
    awk -v p="$buffer" 'BEGIN{ ORS=""; RS=">"; FS="\\n" } $1 == p { print ">" $0 }' !{params.GENOME}  > uniq_out
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
    !{params.BLASTP} -db !{params.NCBI} -outfmt '!{order}' -query "!{uniq_seq}" -out "!{baseDir}/$contig.txt" -num_threads !{params.BLAST_CPU}
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
    !{params.BLASTP} -db !{params.NCBI} -query "!{uniq_seqHtml}" -html -out "!{params.OUTPUT}/$contig.html" -num_threads !{params.BLAST_CPU} 
    '''

}

PYTHON="$baseDir/vendor/python/bin/python"


coverages = Channel.create()
coverages.bind(params.cov.replaceAll(',',' '))

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
   $baseDir/scripts/bam_to_coverage.pl ${params.sortedIndexedBam} > coverage
   """
}

coverageFiles = Channel.create()
coverages.toList().into(coverageFiles)

process createOverview {
   
   cpus 2

   memory '4 GB'

   input:
   file blast_all
   file uniq_overview
   val coverageFiles

   output:
   val params.OUTPUT + '/overview.txt' into over

   """
   #!/bin/sh
   $PYTHON $baseDir/scripts/create_overview.py -u ${uniq_overview}  -faa $baseDir -o ${params.OUTPUT}  -c ${coverageFiles.join(' ')} 
   """
}

process linkSearch {
   
   cpus 2

   memory '4 GB'

   input: 
   val x from over
   params.OUTPUT

   output:
   val params.OUTPUT into inputF 

   """
   #!/bin/sh
   $PYTHON $baseDir/scripts/link_search.py -o ${x} -out ${params.OUTPUT} 
   touch hier.txt
   """
}


process folderToPubmed {
   
   cpus 2

   memory '4 GB'

   input:
   val inp from inputF
   params.OUTPUT

   output:
   val params.OUTPUT + '/all.pubHits'  into pub
   val params.OUTPUT + '/overview.txt' into over2

   """
   #!/bin/sh
   sh $baseDir/scripts/FolderToPubmed.sh ${inp} ${params.OUTPUT}  $baseDir/scripts/UrltoPubmedID.sh
   """
}


process linkAssignment {
 
   cpus 2
 
   memory '6 GB'

   input:
   val x from over2
   val p from pub

   output:
   val params.OUTPUT + '/overview_new.txt' into overNew

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
    $PYTHON $baseDir/scripts/web/controller.py -o ${overview} -out ${params.OUTPUT} -conf $baseDir/scripts/web/config.yaml -templates $baseDir/scripts/web/app/templates
    """

}
