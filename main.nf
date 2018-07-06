#!/usr/bin/env nextflow

/*
vim: syntax=groovy
-*- mode: groovy;-*-
*/

/*
 * ###################################################
 * #                  MeRaGENE                       #
 * # Metagenomics rapid gene identification pipeline #
 * ###################################################
 * 
 * @Authors
 * Benedikt Osterholz
 * Peter Belmann 
 * Wiebke Paetzold
 * Annika Fust
 * Madis Rumming
 */

// Basic parameters. Parameters defined in the .config file will overide these
params.input_folder = "$baseDir/data/test_data/genome"
params.blast = 'blastn'
params.blast_cpu = 8
params.blast_db = "$baseDir/data/test_data/resFinderDB_19042018"
params.output_folder = "$baseDir/out"
params.help = ''
params.nfRequiredVersion = '0.30.0'
params.version = '0.1.1'

// Check if the used Nextflow version is compatible 
if( ! nextflow.version.matches(">= ${params.nfRequiredVersion}") ){
  println("Your Nextflow version is too old, ${params.nfRequiredVersion} is the minimum requirement")
  exit(1)

params.help = ''}

// Show the help page if the --help tag is set while caling the main.nf
if (params.help) exit 0, help()

// First Message that pops up, showing the used parameters and the MeRaGENE version number 
runMessage()

// Set input parameters:
query = Channel.fromPath( "${params.input_folder}/*", type: 'file' )
	.ifEmpty { error "No file found in your input directory ${params.input_folder}"}
	.map { file -> tuple(file.simpleName, file) }
outDir = file(params.output_folder) 
blast_db = file(params.blast_db)

//Check if the input/output paths exist
if( !blast_db.exists() ) exit 1, "The input database does not exist: ${blast_db}"
if( !outDir.exists() && !outDir.mkdirs() ) exit 1, "The output folder could not be created: ${outDir} - Do you have permissions?"


process test {
	
	echo true	
	
	input:
	set name, file(input) from query
	
	script:
  	"""
	echo ${name} - ${input}
	"""
}

// The contend of the help page is defined here:
def help() {
	log.info "----------------------------------------------------------------"
	log.info ""
	log.info " Welcome to the MeRaGENE ~ version ${params.version} ~ help page"	
	log.info "    Usage:"
	log.info "           --help    Call this help page"
}

// The contend of the first message prompt is defined here:
def runMessage() {
	log.info "\n"
	log.info "MeRaGENE ~ version ${params.version}"
	log.info "------------------------------------"
	log.info "input_folder  :${params.input_folder}"
	log.info "output_folder :${params.output_folder}"
	log.info "blast_db      :${params.blast_db}"
	log.info "\n"
}
