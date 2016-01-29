#' @docType package
#' @name miRBaseVersions.db
#' @title miRBaseVersions.db: miRNA name collection of 21 different miRBase
#' release versions.
#' @details This annotation package holds mature miRNA names from 21 different
#' miRBase versions. It contains one main table holding all miRNAs and
#' one view for each version, such as 'vw-mimat-21.0' for mature miRNA names
#' from version 21.0.
#' @import AnnotationDbi
#' @author Stefan Haunsberger \email{stefanhaunsberger@rcsi.ie}
# @examples
# #direct targets in mouse aggregated from all sources:
# targets_mouse <- getPredictedTargets('let-7a',species='mmu', method='geom')
# #homology-translated targets in rat aggregated from all sources
# targets_rat <- getPredictedTargets('let-7a',species='mmu', method='geom')
NULL

datacache = new.env(hash=TRUE, parent=emptyenv())

mirbaseversions_dbconn = function() dbconn(datacache)
mirbaseversions_dbfile = function() dbfile(datacache)

mirbaseversionsORGANISM = "Multiple"

# The .onLoad will be called when the package is loaded.
.onLoad = function(libname, pkgname) {

    # Connect to the SQLite database
    sPkgname = sub(".db$","",pkgname);
    ## Database file
    dbfile = system.file("extdata", paste0(sPkgname, ".sqlite"),
                         package = pkgname, lib.loc=libname)
    assign("dbfile", dbfile, envir = datacache);
    ## Establish database connection
    dbconn = AnnotationDbi::dbFileConnect(dbfile);
    assign("dbconn", dbconn, envir=datacache);

    # Define class

    # library(AnnotationDbi)
    #' @title Database class
    #' @aliases MiRBaseVersionsDb columns keys keytypes select
    #' @description object of \code{MiRBaseVersionsDb} class holds the sqlite
    #' database connection, and extends \code{AnnotationDb} class from AnnotationDbi
    #' package. \code{columns}, \code{keys}, \code{keytypes} and \code{select}
    #' methods allow access to database tables and retrieval of miRNA target
    #' information.
    #'
    #' \code{select} is for querying the database to retrieve information about
    #' mature miRNA names from selected versions.
    #' @usage columns(x)
    #' keytypes(x)
    #' keys(x, keytype)
    #' select(x, keys, columns, keytype)
    #' @param x the \code{MiRBaseVersionsDb} object
    #' @param keytype represents the table from which data shall be received. All
    #' possible keytypes can be viewed by using the \code{keytypes} method.
    #' @param keys the accession name of mature miRNAs. All possible keys (miRNAs)
    #' are returned by using the \code{keys} method.
    #' @param columns that can be returned for each miRNA. All possible columns can
    #' shown by using the \code{columns} method.
    #' @return string vectors, for \code{select} a data.frame with selected columns.
    #' @author Stefan Haunsberger \email{stefanhaunsberger@rcsi.ie}
    #' @exportClass MiRBaseVersionsDb
    #' @examples
    #' #first load the annotations
    #' require(miRBaseVersions.db)
    #' #see all available tables
    #' keytypes(miRBaseVersions.db)

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

    #' @rdname MiRBaseVersionsDb-class
    #' @exportMethod columns
    setMethod(
        f = "columns",
        signature = "MiRBaseVersionsDb",
        definition = function(x) {
            return(.cols(x));
        }
    )

    #' @rdname MiRBaseVersionsDb-class
    #' @exportMethod keytypes
    setMethod(
        f = "keytypes",
        signature = "MiRBaseVersionsDb",
        definition = function(x) {
            # return(.cols(x));
            return(names(.getTableNames(x)));
        }
    )

    #' @rdname MiRBaseVersionsDb-class
    #' @exportMethod keys
    setMethod(
        f = "keys",
        signature = "MiRBaseVersionsDb",
        definition = function(x, keytype) {
            return(.keys(x, keytype));
        }
    )

    # Create the OrgDb object
    ## Use information stored in the metadata table
    txdb = AnnotationDbi::loadDb(dbfile,
                                 packageName = pkgname);
    dbNewname = AnnotationDbi:::dbObjectName(pkgname, "MiRBaseVersionsDb");
    ns = asNamespace(pkgname);
    assign(dbNewname, txdb, envir = ns);
    namespaceExport(ns, dbNewname);

    packageStartupMessage(AnnotationDbi:::annoStartupMessages("That's it!!!"))

}

# Disconnect from dbfile on onload package
.onUnload = function(libpath)
{
    dbFileDisconnect(mirbaseversions_dbconn())
}

