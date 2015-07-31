#!/usr/bin/env nextflow

/*
 * If not further specified with --in "writeYourDirectoryHere" the current base directory is used.
 */ 
params.in = "$baseDir"
wDir = file(params.in)

/*
 * Ensure that the given Path is realy a directory to work in.
 */
if( wDir.isDirectory() ) {
	
	outFolder = file("$wDir/out")
	errorFolder = file("$wDir/error")
	
	/*
	 * Check if the folder already exists, if not create.
	 * After the folder is created, change permissions to group project.
	 */
	if( !outFolder.isDirectory() ){
		if( !outFolder.mkdir() ){
			println 'Could not create the "out" folder. Perhaps permissions are missing ?'
		}else{
			outFolder.setPermissions(7,7,0)
		}
	}
	
	if( !errorFolder.isDirectory() ){
		if( !errorFolder.mkdir() ){
			println 'Could not create the "error" folder. Perhaps permissions are missing ?'
		}else{
			errorFolder.setPermissions(7,7,0)
		}
	}

} else {

	println "\n"+"Could not create Folders, $wDir is not a Folder"
	println 'Please use the --in "writeYourDirectoryHere" option, to choose another folder'+"\n"

}
