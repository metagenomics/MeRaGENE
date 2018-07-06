#!/usr/bin/env nextflow

/*
vim: syntax=groovy
-*- mode: groovy;-*-
*/

/*
 * ===================================================
 * =                  MeRaGENE                       =
 * = Metagenomics rapid gene identification pipeline =
 * ===================================================
 * @Authors
 * Benedikt Osterholz
 * Peter Belmann 
 * Wiebke Paetzold
 * Annika Fust
 * Madis Rumming
 */

// Basic parameters. Parameters defined in the .config file will overide these
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
params.nfRequiredVersion = '0.30.0'
params.version = '0.1.1'

//Check if the used Nextflow version is compatible 
if( ! nextflow.version.matches(">= ${params.nfRequiredVersion}") ){
  println("Your Nextflow version is too old, ${params.nfRequiredVersion} is the minimum requirement")
  exit(1)
}

// Show the help page
if (params.help) exit 0, help()

process test {

	echo true

  	script:
  	"echo Hello"
}

//the contend of the help page is defined here
def help() {
	log.info "----------------------------------------------------------------"
	log.info ""
	log.info " Welcome to the MeRaGENE ~ version ${params.version} ~ help page"	
	log.info "    Usage:"
	log.info "           --help    Call this help page"
}
