# This function populates the mi2mimat sqlite table
#	It the downloaded file from miRBase as input
# 
# Author: stefanhaunsberger
###############################################################################


insertOrganism = function(input.path, db, uri, verbose = TRUE) {
	
	args <- as.list(match.call());
	
	if (is.null(args$input.path)) {
		input.path = file.path("doc", "miRBase", "organisms.txt");
		input.file = file.path(input.path, "organisms.txt");
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
	
	org = read.table(file = input.file, header = TRUE, sep = "\t", stringsAsFactors = FALSE);
	
	# Populate table
	dbWriteTable(conn = db, name = "organism", value = org, row.names = FALSE, overwrite = TRUE);
	
	if (is.null(args$db)) {
		writeLines("Disconnect from db 'miRBase'.");
		dbDisconnect(db);
	}
	
	return();
	
}
