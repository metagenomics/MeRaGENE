#!/usr/bin/env nextflow

process hmmFolderScan {

    cpus "${params.HMM.CPU}"

    memory '4 GB'

    input:
    file hmmInput from '${params.HMM.INPUT}'   

    output:
    file domtblout
    file allOut
    file outputFasta 

    """
    #!/bin/sh
    # All HMM files inside the input folder are merged to one big HMM file inside the output folder.
    cat ${params.HMM.INPUT}/*.hmm > allHmm

    # New HMM Databse needs to be indexed and precomputed for HMMScan to work.
    ${params.HMM.PRESS} allHmm

    # Pipeline Folders are created with the help of a subscript.
    sh ${params.CREATEFOLDER} ${params.HMM.OUTPUT}

    #HMMScan qsub grid call.
    ${params.HMM.SCAN} -E ${params.HMM.EVALUE} --domtblout domtblout --cpu ${params.HMM.CPU} -o allOut allHmm ${params.DATABASE}
    touch outputFasta
    """
}

params.num = 1
num = params.num

process uniqer {
 
    input:
    file domtblout
    file outputFasta
    params.num
      
    output:
    stdout result

    """
    $baseDir/uniquer.sh $num domtblout outputFasta
    cat outputFasta 
    """    
}

/*
 * get all stdout printed
 */
result.subscribe { println it }
