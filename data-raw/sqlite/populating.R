# TODO: Add comment
#
# Author: stefanhaunsberger
###############################################################################

rm(list=ls())

source("src/preparation/parseMiRBaseFile.R");
source(file.path(getwd(), "data-raw/sqlite/insertMI.R"));
source("data-raw/sqlite/insertMIMAT.R");
source("data-raw/sqlite/insertMI2MIMAT.R");
source("data-raw/sqlite/insertOrganisms.R");
source("data-raw/sqlite/insertVersions.R");
source("data-raw/sqlite/insertOrganisms.R");

require(DBI);
require(RSQLite);
# This connection creates an empty database if it does not exist
if (verbose) {
writeLines("Trying to establish connection to miRBaseNames.db");
}

# db = dbConnect(SQLite(), dbname = file.path(getwd(), "data-raw", "sqlite", "miRBaseNames.db"));
db = dbConnect(SQLite(), dbname = file.path(getwd(), "data-raw", "sqlite", "miRBaseVersions.sqlite"));
if (verbose) {
writeLines("Connection ot miRBaseNames.db successfully established.");
}


# Parse miRBase files
mbf = parseMiRBaseFile();

# Populate sqlite tables
insertOrganism(db=db)
file.versions = file.choose();
insertVersions(input.file = file.versions, db = db)
insertMI(df = mbf$mi, db = db);
insertMIMAT(df = mbf$mimat, db = db);
insertMI2MIMAT(df = mbf$mi2mimat, db = db);


# Close connection to db
dbDisconnect(db)


