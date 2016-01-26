# TODO: Add comment
# 
# Author: stefanhaunsberger
###############################################################################


library(DBI);
library(RSQLite);
# This connection creates an empty database if it does not exist
uri = file.path("doc", "db", "miRBaseNames.db");
db = dbConnect(SQLite(), dbname = uri);

# For tables
dbListTables(db);
# For fields in a table
dbListFields(db, "version");

####################################################

## Create mimat table views for the versions respectively

# Read versions
df.version = dbReadTable(db, "version");
# Submit create-table-query
invisible(sapply(df.version$number, function (version) {
					dbSendQuery(conn = db,
							sprintf(
"CREATE VIEW [vw-mimat-%2.1f] AS
	SELECT *
	FROM mimat
	WHERE version == %2.1f;", version, version));
				}));


#sapply(df.version$number, function (version) {
#			sprintf(
#					"CREATE VIEW [vw-mimat-%2.1f] AS
#							SELECT *
#							FROM mimat
#							WHERE version == %2.1f;"
#					, version, version);
#		})

#sapply(as.character(df.version$number), function (version) {
#			sprintf(
#"CREATE VIEW [vw-mimat-%s] AS
#	SELECT *
#	FROM mimat
#	WHERE version == %s;"
#			, version, version);
#		})
#
#sapply(as.character(df.version$number), function (version) {
#			paste0("CREATE VIEW [vw-mimat-", version, "] AS \nSELECT * \nFROM mimat \nWHERE version == ", version, ";");
#		})

####################################################

####################################################

## Create unique miRNA view
dbSendQuery(conn = db,
"CREATE VIEW [vw-mimat-mirna-unique] AS
	SELECT DISTINCT name
   FROM mimat;");





####################################################

## Create view of miRNAs that swapped MIMAT among versions
dbSendQuery(conn = db,
"CREATE VIEW [vw-mimat-mirna-swapped-mimat] AS
	SELECT name FROM (
		SELECT name, count(*) as frequency FROM (
			SELECT DISTINCT accession, name FROM mimat
		)
	GROUP BY name)
	WHERE frequency > 1;");


				
				
				
				
# Close connection to db
dbDisconnect(db);
