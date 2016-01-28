#' @docType package
#' @name miRBaseVersions.db
#' @title miRNAtap: microRNA Targets - Aggregated Predictions.
#' @details It is a package with tools to facilitate implementation of workflows
#' requiring miRNA prediction through access to multiple prediction results
#' (DIANA, Targetscan, PicTar and Miranda) and their aggregation.
#' Three aggregation methods are available: minimum, maximum and geometric mean,
#' additional parameters provide further tuning of the results.
#' Predictions are available for Homo sapiens, Mus musculus
#' and Rattus norvegicus (the last one through homology translation).
#' @import AnnotationDbi RSQLite DBI stringr sqldf plyr methods
#' @author Maciej Pajak \email{m.pajak@@sms.ed.ac.uk}, Ian Simpson
#' @examples
#' #direct targets in mouse aggregated from all sources:
#' targets_mouse <- getPredictedTargets('let-7a',species='mmu', method='geom')
#' #homology-translated targets in rat aggregated from all sources
#' targets_rat <- getPredictedTargets('let-7a',species='mmu', method='geom')
NULL


library(AnnotationDbi)

.MiRBaseVersionsDb = setRefClass(
    Class = "MiRBaseVersionsDb",

    #     slots = representation(
    #         name = "character"
    #     ),
    #
    #     prototype = list(
    #         name = "testMiRBaseVersionsDb"
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
    tables = grep("vw-mimat-[0-9]+\\.[0-9]$|^\\bmimat\\b",
                    dbListTables(con), value = TRUE);
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
    signature = "MiRBaseVersionsDb",
    # definition = .cols(this)
    definition = function(x) {
        return(.cols(x));
    }
)

# @rdname
# @exportMethod columns
setMethod(
    f = "keytypes",
    signature = "MiRBaseVersionsDb",
    # definition = .cols(this)
    definition = function(x) {
        # return(.cols(x));
        return(names(.getTableNames(x)));
    }
)

# @rdname
# @exportMethod keys
setMethod(
    f = "keys",
    signature = "MiRBaseVersionsDb",
    definition = function(x, keytype) {
        return(.keys(x, keytype));
    }
)
