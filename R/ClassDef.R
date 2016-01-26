
library(AnnotationDbi)

# mirbasenames_dbconn = function() AnnotationDbi::dbconn(datacache)
# mirbasenames_dbfile = function() AnnotationDbi::dbfile(datacache)

.MiRBaseNamesDb = setRefClass(
    Class = "MiRBaseNamesDb",

    #     slots = representation(
    #         name = "character"
    #     ),
    #
    #     prototype = list(
    #         name = "testMiRBaseNamesDb"
    #     ),
    contains = "AnnotationDb"

)


#' Get column names
.getLCColnames = function(x) {
    # Retrieve tables names from database
    con = AnnotationDbi::dbconn(x);
    tables = dbListTables(con);
    ## Only select columsn from one view
    # cols = grep("vw-mimat-[0-9]+\\.[0-9]$|organism",
    #               dbListTables(con), value = TRUE);
    # cols = grep("vw-mimat-[0-9]+\\.[0-9]$", dbListTables(con), value = TRUE);
    cols = (dbGetQuery(con, "PRAGMA table_info(\"vw-mimat-21.0\")"))$name;
    return(cols);
}

.cols = function(x)
{
    cols = .getLCColnames(x);
    cols = toupper(cols);
    return(cols);
}

.getTableNames = function(x)
{
#     LC = .getLCColnames(x);
#     UC = .cols(x);
    con = AnnotationDbi::dbconn(x);
    ## Receive table names
    tables = grep("vw-mimat-[0-9]+\\.[0-9]$", dbListTables(con), value = TRUE);
    names(tables) = toupper(tables);
    return(tables);
}

.keys = function(x, keytype)
{
    ## translate keytype back to table name
    tabNames = .getTableNames(x);
    lckeytype = names(tabNames[tabNames %in% keytype]);
    if (length(lckeytype) == 0) {
        # message(sprintf("keytype '%s' not present.", keytype));
        stop(paste("keytype", keytype, "not present.",
                    "Please use method 'keytypes()' to check out the keytypes."
                   ));
    }
    ## get a connection
    con = AnnotationDbi::dbconn(x);
    sql = character();
#     if (length(grep("^vw.+", lckeytype, ignore.case = TRUE)) > 0) {
#         sql = paste0("SELECT accession FROM \"", lckeytype, "\"");
#     } else if (lckeytype == "organism") {
#         sql = paste0("SELECT organism FROM \"", lckeytype, "\"");
#     }
    sql = paste0("SELECT accession FROM \"", lckeytype, "\"");
    res = dbGetQuery(con, sql);
    res = as.vector(t(res));
    return(res);
}

# @rdname
# @exportMethod columns
setMethod(
    f = "columns",
    signature = "MiRBaseNamesDb",
    # definition = .cols(this)
    definition = function(x) {
        return(.cols(x));
    }
)

# @rdname
# @exportMethod columns
setMethod(
    f = "keytypes",
    signature = "MiRBaseNamesDb",
    # definition = .cols(this)
    definition = function(x) {
        # return(.cols(x));
        return(.getTableNames(x))
    }
)

# @rdname
# @exportMethod keys
setMethod(
    f = "keys",
    signature = "MiRBaseNamesDb",
    definition = function(x, keytype) {
        return(.keys(x, keytype));
    }
)
