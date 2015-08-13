#!/usr/bin/env nextflow

/*
 * Script, to get uniq contigs in a desired number.
 * Usage nextflow run --in "" --out "" --num "nummber of hits per contig" uniquer.nf.
 * Choose num = 1 to get only one hit per contig.
 * !! The uniqer.sh script has to be inside $baseDir/scripts !!  
 */

params.in = "$baseDir/input.fa"
params.out ="$baseDir/output.fa"
params.num = 1

input = file(params.in)
out = file(params.out)
num = params.num

process uniqer {
 
    input:
    params.in
    params.out
    params.num
     
    output:
    stdout result
    
    """
    $baseDir/scripts/uniquer.sh $num $input $out  
    """

}

/*
 * get all stdout printed
 */
result.subscribe { println it }
