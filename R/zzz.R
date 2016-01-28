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

