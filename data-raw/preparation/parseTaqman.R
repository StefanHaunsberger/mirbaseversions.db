# TODO: Add comment
# 
# Author: stefanhaunsberger
###############################################################################


parseTaqman = function (input.file) {
	
	args <- as.list(match.call());
	
	if (!is.null(args$input.file)) {
		if (!file.exists(input.file)) {
			stop(writeLines("Input file '%s' does not exist. Please try again with valid file.", input.file));
		}
	} else {
		input.file = file.path("doc", "taqman-ids.xls");
	}
	
	# Load required packages
	writeLines("Loading required packages...");
	require(gdata);		# read.xls
	
	# Read input file
	writeLines(sprintf("Read file '%s'...", input.file));
	data = read.xls(xls = input.file, stringsAsFactors = FALSE, na.strings = "",
							colClasses = c("character", "character", "character", "character", "character", "character"));
	head(data);
	
	# Remove incomplete records
	data = data[complete.cases(data),];
	n.row = nrow(data);
	# Initialize output data frame
	#	- sub data$Assay.ID: remove blanks
	df = data.frame(assay.id = sub("\\s+", "", data$Assay.ID), assay.name = data$Assay.Name,
							target.sequence = data$Target.Sequence, assay.mimat = character(n.row),
							organism = gsub("-.*$", "", data$Assay.Name));
	writeLines("Extract MIMAT-IDs...");
	# Split all MIMAT-IDs and only extract the first entry (at the moment due to simplicity) 
	data.acc.s = strsplit(data$miRBase.Accession.Number, split = "::");
	df$assay.mimat = sapply(data.acc.s, function (x) {
									return(x[[1]][1]);
								});

	writeLines("Done.");
	
	return(df);
	
}


