# This function reads all miRNA files in a given directory.
#	It processes the names and extracts the version number.
#	The versions can be saved to a text file.
#	Return value is a list containing version numbers and files.
# 
# Author: stefanhaunsberger
###############################################################################


processVersionNumbers = function (input.path, save = TRUE) {
	
#	input.path = file.path("doc", "raw-files", "miRBase");
	
	args <- as.list(match.call());
	
	if (is.null(args$input.path)) {
		input.path = file.path("doc", "miRBase", "raw-files");
		if (!file.exists(input.path)) {
			message(sprintf("Default file '%s' does not exist.", input.path));
			stop("Please provide input path or filename.");
		}
		message(sprintf("Set input.path to '%s'...", input.path));
	}
	
	# Set output path
	if (save) {
		output.path= file.path("doc", "miRBase");
		output.file = file.path(output.path, "versions.txt");
		message(sprintf("Set output.path to '%s'...", output.file));
	}
	
	# List files in directory
	files = list.files(input.path, pattern = "miRBase-");
	
	if (length(files) == 0) {
		stop(sprintf("No files in the given input path '%s'.", input.path));
	}
	
	# Order files
	files = files[mixedorder(files)];
	n.files = length(files);
	
	filenames = gsub(pattern = "(\\.xls|\\.xlsx)", replacement = "", x = files);
	versions = as.numeric(sub(pattern = "[a-zA-Z-]+", replacement = "", x = filenames));
	
	# Write versions to file
	df.versions = data.frame(number = as.numeric(versions), information = character(length(versions)));
	if (save) {
		write.table(df.versions, file = output.file, row.names = FALSE, sep = "\t", quote = FALSE)
	}
	
	# Return a list with two entries: versions and files
	return(list(versions = versions, files = files));
	
}
