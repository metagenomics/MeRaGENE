#!/usr/bin/env nextflow

params.overview
params.pubhits

PYTHON="$baseDir/../vendor/python/bin/python"

process linkAssignment {
   cpus 2

   memory '6 GB'

   input: 
   params.overview
   params.pubhits

   """
   #!/bin/sh
   $PYTHON $baseDir/link_assignment.py -o ${params.overview}  -pub ${params.pubhits} 
   """
}
