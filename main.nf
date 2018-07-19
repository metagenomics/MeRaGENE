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
params.blast_db = "$baseDir/data/test_data/resFinderDB_19042018/*.fsa"
params.output_folder = "$baseDir/out"
params.help = ''
params.nfRequiredVersion = '0.30.0'
params.version = '0.1.1'
params.s3 = ''

// Check if the used Nextflow version is compatible 
if( ! nextflow.version.matches(">= ${params.nfRequiredVersion}") ){
  println("Your Nextflow version is too old, ${params.nfRequiredVersion} is the minimum requirement")
  exit(1)}

// Show the help page if the --help tag is set while calling the main.nf
if (params.help) exit 0, help()

// First Message that pops up, showing the used parameters and the MeRaGENE version number 
runMessage()

// If S3 mode is used the starting query has to come out of S3
if(params.s3){
	// Get S3 input files and create output folder
	process getS3Input_createOutput{
		
		output:
		file "*" into s3_input

		script:
		"""
		${baseDir}/data/tools/minio/mc cp --recursive openstack/MeRaGENE/input/ .
		${baseDir}/data/tools/minio/mc mb openstack/MeRaGENE/output/ 
		"""
	}

	s3_input.map{ file -> tuple(file.simpleName, file) }.set{ query }
	// Set outDir manually for S3 mode. S3 has to be set even if not used.
	outDir = file("$baseDir/out") 
}
else{

// Set input parameters if S3 is not selected:
query = Channel.fromPath( "${params.input_folder}/*", type: 'file' )
	.ifEmpty { error "No file found in your input directory ${params.input_folder}"}
	.map { file -> tuple(file.simpleName, file) }
outDir = file(params.output_folder)
} 

// Set input parameters:
blast_db = Channel.fromPath(params.blast_db, type: 'file' )
		.ifEmpty { error "No database found in your blast_db directory ${params.blast_db}"}

//Check if the input/output paths exist
if( !outDir.exists() && !outDir.mkdirs() ) exit 1, "The output folder could not be created: ${outDir} - Do you have permissions?"

process blast {
	
	// Tag each process with a unique name for better overview/debuging
	tag {seqName + "-" + dbName }
	// After process completion a copy of the result is made in this folder	
	publishDir "${outDir}/${seqName}", mode: 'copy'
	
	input:
	// Not file(db) so that complete path is used to find the db, not only the linked file 
	each db from blast_db
	set seqName, file(seqFile) from query

	output:
	set seqName, file("${seqName}_${dbName}.blast") into blast_output
	
	script:
	// No channel with sets used, because *each set* does not work together. So baseName is determined in a single step  
	dbName = db.baseName

  	"""
	${params.blast} -db ${db} -query ${seqFile} -num_threads ${params.blast_cpu} -outfmt 6 -out ${seqName}_${dbName}.blast
	"""
}

process getSubjectCoverage {
	
	echo true
	// Tag each process with a unique name for better overview/debuging
	tag {blast}
	// After process completion a copy of the result is made in this folder 	
	publishDir "${outDir}/${seqName}", mode: 'copy'

	input:
	set seqName, file(blast) from blast_output

	output:
	file out into s3_upload

	script:
	fileName = blast.baseName 
	"""
	echo ${seqName} - ${blast} - ${fileName} > out
	"""
}

if(params.s3){

	process uploadResults {
	
		input:
		file 'finish_*' from s3_upload.collect()

		script:
		"""
		${baseDir}/data/tools/minio/mc cp --recursive $baseDir/out/  openstack/MeRaGENE/output/
		"""
	}
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
	// If S3 mode is used paths are fixed 
	if(params.s3){	
	log.info "input_folder  :S3:/MeRaGENE/input"
	log.info "output_folder :S3:/MeRaGENE/output"}
	else{
	log.info "input_folder  :${params.input_folder}"
	log.info "output_folder :${params.output_folder}"}
	log.info "blast version :${params.blast}"
	log.info "blast_db      :${params.blast_db}"
	log.info "blast_cpu     :${params.blast_cpu}"
	log.info "\n"
}
