
library(AnnotationDbi)

.MiRBaseVersionsDb = setRefClass(
    Class = "MiRBaseVersionsDb",
    contains = "AnnotationDb"

)


#' @title Lower case columns function implementation
#' @details This function reads column names from the view of the
#' current version in lower case. All visible keytypes have the same columns.
#' @param MiRBaseVersionsDb object reference
#' @return Character vector with lower case column names.
.getLCColnames = function(x) {
    # Retrieve tables names from database
    con = AnnotationDbi::dbconn(x);
    ## Only select columsn from one view
    # cols = grep("vw-mimat-[0-9]+\\.[0-9]$|organism",
    #               dbListTables(con), value = TRUE);
    # cols = grep("vw-mimat-[0-9]+\\.[0-9]$", dbListTables(con), value = TRUE);
    cols = (dbGetQuery(con, "PRAGMA table_info('vw-mimat-21.0')"))$name;
    return(cols);
}

#' @title Internal \code{columns} function implementation
#' @details This function converts lower case column names (received from
#' \code{\link{.getLCColNames}}) into upper case.
#' @param MiRBaseVersionsDb object reference
#' @return Character vector containing upper case column names
.cols = function(x)
{
    cols = .getLCColnames(x);
    cols = toupper(cols);
    return(cols);
}

#' @title Internal \code{keytypes} implementation
#' @details The \code{.getTableNames} function reads table names from the
#' database. Two types of tables will be returned, the general mimat table and
#' views respectively for each miRBase version.
#' @param MiRBaseVersionsDb object reference
#' @return Character vector where the values are lower name and the 'name'
#' attribute are upper name table names.
.getTableNames = function(x)
{
    con = AnnotationDbi::dbconn(x);
    ## Receive table names
    tables = grep("vw-mimat-[0-9]+\\.[0-9]$|^\\bmimat\\b",
                  dbListTables(con), value = TRUE);
    names(tables) = toupper(tables);
    return(tables);
}

#' @title Internal \code{keys} function implementation
#' @details The \code{.keys} function implementation reads the accessions of the
#' desired keytype.
#' @param MiRBaseVersionsDb object reference
#' @return Character vector with accession names from specified \code{keytype}
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

#' @rdname miRBaseVersions.db
#' @exportMethod columns
setMethod(
    f = "columns",
    signature = "MiRBaseVersionsDb",
    # definition = .cols(this)
    definition = function(x) {
        return(.cols(x));
    }
)

#' @rdname miRBaseVersions.db
#' @exportMethod keytypes
setMethod(
    f = "keytypes",
    signature = "MiRBaseVersionsDb",
    # definition = .cols(this)
    definition = function(x) {
        # return(.cols(x));
        return(names(.getTableNames(x)));
    }
)

#' @rdname miRBaseVersions.db
#' @exportMethod keys
setMethod(
    f = "keys",
    signature = "MiRBaseVersionsDb",
    definition = function(x, keytype) {
        return(.keys(x, keytype));
    }
)
