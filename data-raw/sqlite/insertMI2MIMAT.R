# This function populates the mi2mimat sqlite table
#	It either takes an input file (tab separated text file) or a df
# 
# Author: stefanhaunsberger
###############################################################################


insertMI2MIMAT = function(input.file, df, db, uri, verbose = TRUE) {
	
	args <- as.list(match.call());
	
#	if (all(is.null(args$input.path), is.null(args$df))) {
#		stop("Please provide input path or filename.");
#	}
	input.path = character();
	if (all(is.null(args$input.file), is.null(args$df))) {
		input.path = file.path("doc", "miRBase");
		input.file = file.path(input.path, "mi2mimat-data.txt");
		if (!file.exists(input.path)) {
			message(sprintf("Default file '%s' does not exist.", input.file));
			stop("Please provide input path or filename.");
		}
		message(sprintf("Set input.file to '%s'...", input.file));
	}
	
	if (is.null(args$db)) {
		if (is.null(args$uri)) {
#			stop("Please provide either 'db' or 'uri'.");
			uri = file.path("doc", "db", "miRBaseNames.db");
			message(sprintf("Set uri to '%s'.", uri));
		}
		if (verbose) {
			writeLines("Loading required packages...");
		}
		require(DBI);
		require(RSQLite);
		# This connection creates an empty database if it does not exist
		if (verbose) {
			writeLines("Trying to establish connection to miRBaseNames.db");
		}
		db <- dbConnect(SQLite(), dbname = uri);
		if (verbose) {
			writeLines("Connection ot miRBaseNames.db successfully established.");
		}
	}
#	if (verbose) {
#		writeLines("Delete table content from table 'organism'.");
#	}
#	dbSendQuery(db, "DELETE FROM organism");
	
	if (length(input.path) != 0) {
		df = read.table(file = input.file, header = TRUE, sep = "\t", stringsAsFactors = FALSE);
	}
	if (!all(colnames(df) == dbListFields(db, "mi2mimat"))) {
		stop("Columns names don't match");	
	}
	
	writeLines(sprintf("Inserting %i records into table 'mi2mimat'...", nrow(df)));
	# Populate table
	dbWriteTable(conn = db, name = "mi2mimat", value = df, row.names = FALSE, overwrite = TRUE);
	
	if (is.null(args$db)) {
		writeLines("Disconnect from db 'miRBase'.");
		dbDisconnect(db);
	}
	
	return();
	
}
