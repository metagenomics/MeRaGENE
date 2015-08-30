#!/usr/bin/env nextflow

params.overview
params.output

PYTHON="$baseDir/../vendor/python/bin/python"

process createOverview {
   
   cpus 2

   memory '4 GB'

   input: 
   params.overview
   params.output
   
   """
   #!/bin/sh
   $PYTHON $baseDir/link_search.py -o ${params.overview}  -out ${params.output} 
   """
}
