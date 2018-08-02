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
//!!!!! If pblastn is used, the coverage calculation has to adapt by dividing by 3 !!!!
params.blast = 'blastn'
params.blast_cpu = 8
params.blast_db = "$baseDir/data/databases/resFinderDB_19042018/*.fsa"
params.output_folder = "$baseDir/out"
params.help = ''
params.nfRequiredVersion = '0.30.0'
params.version = '0.1.1'
params.s3 = ''
// If docker is used the blastDB path will not be included in the volume mountpoint because it is a path, not a file
// This dummy file is inside the databse folder doing the job, so that the path is mounted into the docker instance 
docker_anker = file("$baseDir/data/databases/docker_anker")

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
	// Set outDir manually for S3 mode. The outDir has to be set even if not used.
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
	
	// Tag each process with a unique name for better overview/debugging
	tag {seqName + "-" + dbName }
	// If the blast output is not named "empty.blast", a copy is put into the publishDir	
	publishDir "${outDir}/${seqName}", mode: 'copy', saveAs: { it == 'empty.blast' ? null : it }
	
	// Docker blast container which this process is executed in 	
	container 'biocontainers/blast:v2.2.31_cv1.13'
	
	input:
	// Not file(db) so that complete path is used to find the db, not only the linked file 
	each db from blast_db
	set seqName, file(seqFile) from query
	// Has to be a file to include the database folder into the docker volume mount path
	file(docker_anker)

	output:
	set seqName, file("*.blast") into blast_output
	
	script:
	// No channel with sets used, because *each set* do not work together. So baseName is determined in a single step  
	dbName = db.baseName
	// After the input is blasted, the output is checked for contend. If it is empty, it is renamed to "empty.blast" to be removed later. 
  	"""
	head ${docker_anker}
	${params.blast} -db ${db} -query ${seqFile} -num_threads ${params.blast_cpu} -outfmt "6 qseqid sseqid pident length qlen slen mismatch gapopen qstart qend sstart send evalue bitscore qcovs" -out ${seqName}_${dbName}.blast
	if [ ! -s ${seqName}_${dbName}.blast ]; then mv ${seqName}_${dbName}.blast empty.blast; fi 
	"""
}

// Empty blast outputs are removed by this filter step, [1] because it is a set
blast_output.filter{!it[1].isEmpty()}.set{subject_covarage_input}

// Calculate the missing subject covarage and add it to the blast output
process getSubjectCoverage {
	
	echo true
	// Tag each process with a unique name for better overview/debugging
	tag {blast}
	// After process completion a copy of the result is made in this folder 	
	publishDir "${outDir}/${seqName}", mode: 'copy'

	input:
	set seqName, file(blast) from subject_covarage_input

	output:
	set seqName, file("${blast}.cov") into get_coverage_output

	shell:
	//!!!! If a protein blast is used, the coverage has to be divided by 3 !!!!
	// Calculation: ( ( (SubjectAlignment_End - SubjectAlignment_Start + 1) / SubjectLength) * (Identity/100) ) 
	'''
	while read p; do
                cov=$(awk '{ print ((($12-$11+1)/$6)*($3/100)) }' <<< $p);
                echo "$p\t$cov" >> !{blast}.cov;
        done < !{blast}
	'''
}

// Create a dot plot of the blast-coverage results 
process createDotPlots {

	tag {coverage}
	
	publishDir "${outDir}/${seqName}", mode: 'copy'

	container 'meragene_python'

	input:
	set seqName, file(coverage) from get_coverage_output

 
	output:
	file("*.png") into s3_upload
	
	// A prebuild executable of the createDotPlot.py is used to execute this process
	script:
	"""
	python /app/createDotPlot.py ${coverage} .  
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

// The contend of the overview message prompt is defined here:
def runMessage() {
	log.info "\n"
	log.info "MeRaGENE ~ version " + params.version
	log.info "------------------------------------"
	log.info "config file   : " + workflow.configFiles
	// If S3 mode is used paths are fixed 
	if(params.s3){	
	log.info "input_folder  : S3:/MeRaGENE/input"
	log.info "output_folder : S3:/MeRaGENE/output"}
	else{
	log.info "input_folder  : " + params.input_folder
	log.info "output_folder : " + params.output_folder} 
	log.info "blast version : " + params.blast 
	log.info "blast_db      : " + params.blast_db 
	log.info "blast_cpu     : " + params.blast_cpu 
	log.info "\n"
}

// Overview message prompt after the workflow is finished 
workflow.onComplete {
	this.runMessage()
	log.info "Total runtime : " + workflow.duration
	log.info "Finished at   : " + workflow.complete
	log.info "Success       : " + workflow.success
	log.info "Exit status   : " + workflow.exitStatus
	log.info "Error report  : " + (workflow.errorReport ?: '-')
	log.info "Nextflow      : " + nextflow.version
}

