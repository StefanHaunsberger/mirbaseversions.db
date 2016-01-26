# TODO: Add comment
# 
# Author: stefanhaunsberger
###############################################################################

rm(list=ls())

source("src/preparation/parseMiRBaseFile.R");
source("src/sqlite/insertMI.R");
source("src/sqlite/insertMIMAT.R");
source("src/sqlite/insertMI2MIMAT.R");
source("src/sqlite/insertOrganisms.R");
source("src/sqlite/insertVersions.R");

#require(DBI);
#require(RSQLite);
## This connection creates an empty database if it does not exist
#if (verbose) {
#	writeLines("Trying to establish connection to miRBaseNames.db");
#}
#
#db = dbConnect(SQLite(), dbname = "C:\\sqlite\\miRBaseNames.db");
#if (verbose) {
#	writeLines("Connection ot miRBaseNames.db successfully established.");
#}


# Parse miRBase files
mbf = parseMiRBaseFile();

# Populate sqlite tables
insertMI(df = mbf$mi);
insertMIMAT(df = mbf$mimat);
insertMI2MIMAT(df = mbf$mi2mimat);
file.versions = file.choose();
insertVersions(input.file = file.versions)


# Close connection to db
dbDisconnect(db)


