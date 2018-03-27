datacache = new.env(hash=TRUE, parent=emptyenv())

# mirbaseversions_dbconn = function() dbconn(datacache)
# mirbaseversions_dbfile = function() dbfile(datacache)

mirbaseversionsORGANISM = "Multiple"

#' @docType package
#' @name miRBaseVersions.db
#' @title miRBaseVersions.db: miRNA name collection of 22 different miRBase
#' release versions.
#' @aliases columns keys keytypes select
#' @details This annotation package comprises mature miRNA names from
#' 22 different miRBase versions. It contains one main table holding all miRNAs
#' and one view for each version, such as 'vw-mimat-22.0' for mature miRNA names
#' from version 22.0.
#' @import AnnotationDbi methods DBI RSQLite gtools
#' @author Stefan Haunsberger \email{stefanhaunsberger@rcsi.ie}
#'
#' @description object of \code{MiRBaseVersionsDb} class holds the sqlite
#' database connection, and extends \code{AnnotationDb} class from
#' AnnotationDbi package. \code{columns}, \code{keys}, \code{keytypes} and
#' \code{select} methods allow access to database tables and retrieval of
#' miRNA target information.
#'
#' \code{select} is for querying the database to retrieve information about
#' mature miRNA names from selected versions.
#' @usage columns(x)
#' keytypes(x)
#' keys(x, keytype)
#' select(x, keys, columns, keytype)
#' @param x the \code{miRBaseVersions.db}
#' @param keytype represents the table from which data shall be received.
#' All possible keytypes can be viewed by using the \code{keytypes} method.
#' @param keys the accession name of mature miRNAs. All possible keys
#' (miRNAs) are returned by using the \code{keys} method.
#' @param columns that can be returned for each miRNA. All possible columns
#' can be shown by using the \code{columns} method.
#' @param libname Name of library (automatically passed on at start up)
#' @param pkgname Package name (automatically passed on at start up)
#' @return string vectors, for \code{select} a data.frame with selected
#' columns.
#' @examples
# #first load the annotations
# require(miRBaseVersions.db)
#' # see all available tables
#' keytypes(miRBaseVersions.db)
#' # see column names
#' columns(miRBaseVersions.db)
NULL

# The .onLoad will be called when the package is loaded.
.onLoad = function(libname, pkgname) {

    # library(methods)
    # Connect to the SQLite database
    sPkgname = sub(".db$","",pkgname);
    ## Database file
    dbfile = system.file("extdata", paste0(sPkgname, ".sqlite"),
                         package = pkgname, lib.loc=libname)
    assign("dbfile", dbfile, envir = datacache);
    ## Establish database connection
    dbconn = AnnotationDbi::dbFileConnect(dbfile);
    assign("dbconn", dbconn, envir=datacache);

    ########################################################################
    # Define class

#     if(!exists("MiRBaseVersions", mode="class")) {
#         # stop("first statement ... !!!>!>!>!>!>")
#         if (!file.exists("R/ClassDef.R")) {
#             stop("second statement ... !!>!<!>!><!")
#             # source("R/ClassDef.R")
#         }
#         sys.source(file = "R/ClassDef.R", envir = environment())
#     }

    # @title Database class
    # @aliases MiRBaseVersionsDb columns keys keytypes select
    # @description object of \code{MiRBaseVersionsDb} class holds the sqlite
    # database connection, and extends \code{AnnotationDb} class from
    # AnnotationDbi package. \code{columns}, \code{keys}, \code{keytypes} and
    # \code{select} methods allow access to database tables and retrieval of
    # miRNA target information.
    #
    # \code{select} is for querying the database to retrieve information about
    # mature miRNA names from selected versions.
    # @usage columns(x)
    # keytypes(x)
    # keys(x, keytype)
    # select(x, keys, columns, keytype)
    # @param x the \code{miRBaseVersions.db}
    # @param keytype represents the table from which data shall be received.
    # All possible keytypes can be viewed by using the \code{keytypes} method.
    # @param keys the accession name of mature miRNAs. All possible keys
    # (miRNAs) are returned by using the \code{keys} method.
    # @param columns that can be returned for each miRNA. All possible columns
    # can be shown by using the \code{columns} method.
    # @return string vectors, for \code{select} a data.frame with selected
    # columns.
    # @author Stefan Haunsberger \email{stefanhaunsberger@rcsi.ie}
    # @examples
    # #first load the annotations
    # require(miRBaseVersions.db)
    # #see all available tables
    # keytypes(miRBaseVersions.db)
    # @export MiRBaseVersionsDb
    .MiRBaseVersionsDb = setRefClass(
        Class = "MiRBaseVersionsDb",
        contains = "AnnotationDb"
    )

    # @title Lower case columns function implementation
    # @details This function reads column names from the view of the
    # current version in lower case. All visible keytypes have the same columns.
    # @param MiRBaseVersionsDb object reference
    # @return Character vector with lower case column names.
    .getLCColnames = function(x) {
        # Retrieve tables names from database
        con = AnnotationDbi::dbconn(x);
        ## Only select columsn from one view
        # cols = grep("vw-mimat-[0-9]+\\.[0-9]$|organism",
        #               dbListTables(con), value = TRUE);
        # cols = grep("vw-mimat-[0-9]+\\.[0-9]$", dbListTables(con),
        #               value = TRUE);
        cols = (DBI::dbGetQuery(con,
                                "PRAGMA table_info('vw-mimat-22.0')"))$name;
        return(cols);
    }

    # @title Internal \code{columns} function implementation
    # @details This function converts lower case column names (received from
    # \code{\link{.getLCColNames}}) into upper case.
    # @param MiRBaseVersionsDb object reference
    # @return Character vector containing upper case column names
    .cols = function(x)
    {
        cols = .getLCColnames(x);
        cols = toupper(cols);
        return(cols);
    }

    # @title Internal \code{keytypes} implementation
    # @details The \code{.getTableNames} function reads table names from the
    # database. Two types of tables will be returned, the general mimat table
    # and views respectively for each miRBase version.
    # @param MiRBaseVersionsDb object reference
    # @return Character vector where the values are lower name and the 'name'
    # attribute are upper name table names.
    .getTableNames = function(x)
    {
        con = AnnotationDbi::dbconn(x);
        ## Receive table names
        tables = grep("vw-mimat-[0-9]+\\.[0-9](-hsa)?$|^\\bmimat\\b",
                      DBI::dbListTables(con), value = TRUE);
        names(tables) = toupper(tables);
        return(tables);
    }

    # @title Internal \code{keys} function implementation
    # @details The \code{.keys} function implementation reads the accessions
    # of the desired keytype.
    # @param MiRBaseVersionsDb object reference
    # @return Character vector with accession names from specified
    # \code{keytype}
    .keys = function(x, keytype)
    {
        ## translate keytype back to table name
        tabNames = .getTableNames(x);
        # lckeytype = names(tabNames[tabNames %in% keytype]);
        lckeytype = tabNames[names(tabNames) %in% keytype];
        if (length(lckeytype) == 0) {
            # message(sprintf("keytype '%s' not present.", keytype));
            stop(paste("keytype", keytype, "does not exist.",
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
        ## Execute SQL statement
        res = DBI::dbGetQuery(con, sql);
        res = as.vector(t(res));
        return(res);
    }


    .select = function(x, keys, columns, keytype) {
        ## translate keytype back to table name
        tabNames = .getTableNames(x);
        keytypeLC = tabNames[names(tabNames) %in% keytype];
        if (length(keytypeLC) == 0) {
            stop("Keytype not valid. Please check out 'keytypes'.");
        }
        ## Get columns
        colsSQL = character();
        colsLC = .getLCColnames(x);
        if (any(columns != "*")) {
            colsUC = .cols(x);
            cols = colsLC[colsUC %in% columns];
            colsSQL = paste(cols, collapse = ", ");
        } else {
            colsSQL = "*";
        }
        ## get the connection
        con = AnnotationDbi::dbconn(x);
        sql = sprintf(paste("SELECT %s FROM `%s`",
                            "WHERE UPPER(accession) IN ('%s')"),
                colsSQL, keytypeLC,
                paste(toupper(keys), collapse = "', '"));
        ## Execute SQL statement
        res = DBI::dbGetQuery(con, sql);
        colnames(res) = toupper(colnames(res));
        return(res)
    }

    # @rdname MiRBaseVersionsDb-class
    #' @rdname miRBaseVersions.db
    #' @exportMethod columns
    setMethod(
        f = "columns",
        signature = "MiRBaseVersionsDb",
        definition = function(x) {
            return(.cols(x));
        }
    )

    # @rdname MiRBaseVersionsDb-class
    #' @rdname miRBaseVersions.db
    #' @exportMethod keytypes
    setMethod(
        f = "keytypes",
        signature = "MiRBaseVersionsDb",
        definition = function(x) {
            tables = names(.getTableNames(x))
            ## Order values
            tables = tables[gtools::mixedorder(tables, decreasing = TRUE)];
            return(tables);
        }
    )

    # @rdname MiRBaseVersionsDb-class
    #' @rdname miRBaseVersions.db
    #' @exportMethod keys
    setMethod(
        f = "keys",
        signature = "MiRBaseVersionsDb",
        definition = function(x, keytype) {
            return(.keys(x, keytype));
        }
    )

    # @rdname MiRBaseVersionsDb-class
    #' @rdname miRBaseVersions.db
    #' @exportMethod select
    setMethod(
        f = "select",
        signature = "MiRBaseVersionsDb",
        definition = function(x, keys, columns = "*", keytype = "") {
            .select(x, keys = keys, columns = columns, keytype = keytype);
        }
    )



    ########################################################################

    # Create the OrgDb object
    ## Use information stored in the metadata table
    txdb = AnnotationDbi::loadDb(dbfile,
                                 packageName = pkgname);
    dbNewname = AnnotationDbi:::dbObjectName(pkgname, "MiRBaseVersionsDb");
    ns = asNamespace(pkgname);
    assign(dbNewname, txdb, envir = ns);
    namespaceExport(ns, dbNewname);

    # packageStartupMessage(AnnotationDbi:::annoStartupMessages(""))

}

# Disconnect from dbfile on onload package
# .onUnload = function(libpath)
# {
#     dbFileDisconnect(mirbaseversions_dbconn())
# }
