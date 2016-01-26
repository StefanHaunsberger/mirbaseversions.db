
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
    ## drop unwanted tables
#     unwanted = c("map_counts",
#                  "map_metadata",
#                  "metadata",
#                  "vw.+",
#                  "taqman",
#                  "\\bmi\\b", # Only 'mi' matches but not 'mimat'
#                  "mi2mimat");
#     cols = grep(paste(unwanted, collapse = "|"),
#                 tables,
#                 value = TRUE, invert = TRUE);
    ## Only select views
    cols = grep("vw-mimat-[0-9]+\\.[0-9]$|organism", dbListTables(con), value = TRUE);
    # dbDisconnect(con);
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
    LC = .getLCColnames(x)
    UC = .cols(x)
    names(UC) = LC
    UC
}

.keys = function(this, keytype)
{
    ## translate keytype back to table name
    tabNames = .getTableNames(this);
    lckeytype = names(tabNames[tabNames %in% keytype]);
    print(lckeytype)
    ## get a connection
    con = AnnotationDbi::dbconn(this);
    sql = character();
    if (length(grep("^vw.+", lckeytype, ignore.case = TRUE)) > 0) {
        sql = paste0("SELECT accession FROM \"", lckeytype, "\"");
    } else if (lckeytype == "organism") {
        sql = paste0("SELECT organism FROM \"", lckeytype, "\"");
    }
    print(sql)
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
        return(.cols(x));
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
