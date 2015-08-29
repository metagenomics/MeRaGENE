#!/usr/bin/env nextflow

params.unique
params.faa
params.out
params.cov # comma separated list

PYTHON="$baseDir/../vendor/python/bin/python"

process createOverview {
   cpus 8

   memory '4 GB'

   input: 
   params.unique
   params.faa
   params.out
   params.cov
   
   """
   #!/bin/sh
   $PYTHON $baseDir/create_overview.py -u ${params.unique}  -faa ${params.faa} -o ${params.out}  -c ${params.cov.replaceAll(',',' ')} 
   """
}
