#!/usr/bin/env nextflow

params.inp
params.outp

inp = file(params.inp)
outp = file(params.outp)

process folderToPubmed {

   input: 
   file inp
   file outp

   """
   #!/bin/sh
   sh $baseDir/FolderToPubmed.sh $inp $outp
   """
}
