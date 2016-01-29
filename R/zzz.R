#' @docType package
#' @name miRBaseVersions.db
#' @title miRBaseVersions.db: miRNA name collection of 21 different miRBase
#' releases.
#' @details This annotation package holds mature miRNA names from 21 different
#' miRBase versions. It contains one main table containing all miRNAs and
#' one view for each version, such as 'vw-mimat-21.0' for mature miRNA names
#' from version 21.0.
#' @import AnnotationDbi RSQLite DBI methods
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

.onLoad = function(libname, pkgname) {

    require("methods", quietly=TRUE)
    # Connect to the SQLite database
    sPkgname = sub(".db$","",pkgname);
    ## Database file
    dbfile = system.file("extdata", paste0(sPkgname, ".sqlite"),
                            package = pkgname, lib.loc=libname)
    assign("dbfile", dbfile, envir = datacache);
    # Database connection
    dbconn = AnnotationDbi::dbFileConnect(dbfile);
    assign("dbconn", dbconn, envir=datacache);

    # Create the OrgDb object
    txdb = AnnotationDbi::loadDb(dbfile,
                   packageName = pkgname);
    dbNewname = AnnotationDbi:::dbObjectName(pkgname,"MiRBaseVersionsDb");
    ns = asNamespace(pkgname);
    assign(dbNewname, txdb, envir = ns);
    namespaceExport(ns, dbNewname);

    packageStartupMessage(AnnotationDbi:::annoStartupMessages("That's it!!!"))

}

.onUnload = function(libpath)
{
    dbFileDisconnect(mirbaseversions_dbconn())
}

