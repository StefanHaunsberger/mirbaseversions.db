# This function parses miRNA files from miRBase in xls format.
#	It returns 3 values in a list:
#		- mi: df containing extracted information about mature miRNAs
#		- mimat: df containing information about precursor miRNAs
#		- mi2mimat: link between mi and mimat for the current version
# 
# Author: stefanhaunsberger
###############################################################################

#rm(list = ls());

source("src/preparation/processVersionNumbers.R");

parseMiRBaseFile = function (input.path, save = TRUE, output.path) {

	require(gdata);		# read.xls
	library(gtools);		# mixedorder
	
	verbose = TRUE;
	
#	output.path = file.path("doc", "analysis", "epoxomicin", paste("no-iqr-", Sys.Date(), "-v1", "/", sep = ""));
	
	df.mimat.all = data.frame(accession = character(),
								name = character(),
								sequence = character(),
								version = numeric(),
								organism = character(),
								stringsAsFactors = FALSE);
	
	# Test input path
	#input.path = file.path("doc", "raw-files", "miRBase", "miRBase-15.xls");
	input.path = file.path("doc", "miRBase", "raw-files");
	output.path = file.path("doc", "miRBase");
	
	# Read versions
	val = processVersionNumbers(input.path = input.path, save = TRUE);
	versions = val$versions;
	files = val$files;
	n.files = length(files);
	
	# The highest version
#	max.version = max(as.numeric(versions));
	max.version = max(versions);
	
	for (file in 1:length(files)) {
		
		writeLines(sprintf("\tReading file '%s'... [%i of %i]", files[file], file, n.files));
		# Read data
		data = read.xls(xls = file.path(input.path, files[file]), stringsAsFactors = FALSE, na.strings = "");
		head(data);
		
		# Initialize variables for looping over columns
		n.col.all = ncol(data);
		col.idx.mi.seq = which(colnames(data) == "Sequence");
		col.idx.mimat.acc = col.idx.mi.seq + 1;
		n.col.mimat = n.col.all - col.idx.mi.seq;
		n.col.mimat.group = 3;
		
		if ((n.col.mimat %% n.col.mimat.group) != 0) {
			stop("Number of MIMAT columns is not dividable by 3!");
		}
		
		n.mimat = n.col.mimat / n.col.mimat.group;
		
		n.rows = nrow(data);
		
		# preallocate memory
		n.row.df = (n.rows * n.mimat);
		df.cons = data.frame(accession = character(n.row.df),
									name = character(n.row.df),
									sequence = character(n.row.df),
									version = versions[file],
									organism = character(n.row.df),
									stringsAsFactors = FALSE);
		mimat.groups.idxs = ((0:(n.mimat-1))*3) + col.idx.mimat.acc;
		mimat.groups.idxs.seqs = lapply(mimat.groups.idxs, function(x) {seq(x,x+n.col.mimat.group-1)});
		#
		# Precompute row index vectors
		#
		n.mimat.groups = length(mimat.groups.idxs);
		r.idxs.lo = (((0:(n.mimat.groups-1)) * n.rows) + 1);					# Lower index
		r.idxs.up = (1:(n.mimat.groups) * n.rows);								# Upper index
		r.idx.seq = mapply(seq, r.idxs.lo, r.idxs.up, SIMPLIFY = FALSE);	# List with indices
		if (verbose) {
			writeLines(sprintf("\tProcessing file..."));
		}
		# Add each MIMAT column group to df 
#		# Current miRBase version -> use more content
		if (versions[file] == max.version) {
			df.mi2mimat = data.frame(accession.mi = character(n.row.df),
											accession.mimat = character(n.row.df),
											stringsAsFactors = FALSE);
			df.mi = data.frame(accession = data$Accession,
										name = data$ID,
										sequence = data$Sequence,
										version = versions[file],
										organism = gsub("-.*$", "", data$ID),
										stringsAsFactors = FALSE);
		}
		for (group in 1:n.mimat.groups) {
			
			df.cons[r.idx.seq[[group]],1:n.col.mimat.group] = data[,mimat.groups.idxs.seqs[[group]]];
			# Link MIMAT to MI of current miRBase version
			if (versions[file] == max.version) {
				writeLines(sprintf("Linking MIMAT and MI accessions of version %i...", max.version));
				df.mi2mimat[r.idx.seq[[group]],1:2] = data[,c(1, mimat.groups.idxs.seqs[[group]][1])];
			}
		}
		
		if (verbose) {
			writeLines("\tRemoving incomplete cases...");
		}
		df.cons = unique(df.cons[complete.cases(df.cons),]);
		df.cons$organism = gsub("-.*$", "", df.cons$name);
#		if (verbose) {
#			print(head(df.cons));
#		}
		
		writeLines(sprintf("\tAdding data from version %s to data frame...", versions[file]));
		df.mimat.all = rbind.data.frame(df.mimat.all, df.cons);
		
		
	}	# end of file loop
	
	
	# Manual corrections for MIMAT IDs
	#	e.g. these two derive from the same presursor hairpin
	#			MIMAT0004770	hsa-miR-516a-5p
	#			MIMAT0004771	hsa-miR-516a-5p
	#	where MIMAT0004771 does not exist
	correction = c("MIMAT0004771",
						"MIMAT0002122");
	df.mimat.all = df.mimat.all[!(df.mimat.all$accession %in% correction),];

	
	# Process MI-2-MIMAT table
	df.mi2mimat = df.mi2mimat[complete.cases(df.mi2mimat),];
	if (verbose) {
		head(df.mi2mimat);
	}
	
	if (save) {
		write.table(df.mi, file = file.path(output.path, "mi-data.txt"), quote = FALSE, sep = "\t", row.names = FALSE);
		write.table(df.mimat.all, file = file.path(output.path, "mimat-data.txt"), quote = FALSE, sep = "\t", row.names = FALSE);
		write.table(df.mi2mimat, file = file.path(output.path, "mi2mimat-data.txt"), quote = FALSE, sep = "\t", row.names = FALSE);
	}
	
	writeLines("Done.");
	return(list(mimat = df.mimat.all, mi = df.mi, mi2mimat = df.mi2mimat));
	
}
	
