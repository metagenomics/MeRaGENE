#!/usr/bin/env nextflow

params.sortedIndexedBam

process bamToCoverage {
   
   cpus 2

   memory '4 GB'

   input: 
   params.sortedIndexedBam

   output:
   stdout result
   
   """
   #!/bin/sh
   $baseDir/bam_to_coverage.pl ${params.sortedIndexedBam}
   """

}

result.subscribe {
    println it.trim()
}