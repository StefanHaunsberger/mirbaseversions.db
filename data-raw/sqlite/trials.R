# TODO: Add comment
# 
# Author: stefanhaunsberger
###############################################################################
##
## Refs:
#		https://cran.r-project.org/web/packages/RSQLite/RSQLite.pdf
#		http://www.r-bloggers.com/r-and-sqlite-part-1/
#		http://rstudio-pubs-static.s3.amazonaws.com/8753_a57d3950027541a590c9b40a045accbf.html#9
##


library(DBI);
library(RSQLite);
# This connection creates an empty database if it does not exist
db <- dbConnect(SQLite(), dbname = "C:\\sqlite\\miRBaseNames.db");

# For tables
dbListTables(db);
# For fields in a table
dbListFields(db, "versions");


# Close connection to db
dbDisconnect(db)








