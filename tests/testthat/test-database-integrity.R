#
# Database integrity checks
#
# These tests run against the shipped SQLite asset and are intended to
# catch corruption or shape regressions when the database is regenerated
# (e.g. when adding a new miRBase release).
#
# Author: Stefan Haunsberger
###############################################################################

require(miRBaseVersions.db);

context("database integrity");

con = AnnotationDbi::dbconn(miRBaseVersions.db);

test_that("package object is the expected class with a live connection", {

    expect_s4_class(miRBaseVersions.db, "MiRBaseVersionsDb");
    expect_true(DBI::dbIsValid(con));

})

test_that("base tables and metadata are present", {

    tables = DBI::dbListTables(con);
    for (tbl in c("mi", "mimat", "mi2mimat", "version", "organism", "metadata")) {
        expect_true(tbl %in% tables,
                    info = sprintf("missing base table %s", tbl));
    }

})

test_that("mimat has the expected columns and no NULLs", {

    cols = DBI::dbGetQuery(con, "PRAGMA table_info('mimat')")$name;
    expect_equal(cols, c("accession", "name", "sequence", "version", "organism"));

    nulls = DBI::dbGetQuery(con, paste(
        "SELECT count(*) AS n FROM mimat WHERE",
        "accession IS NULL OR name IS NULL OR sequence IS NULL OR",
        "version IS NULL OR organism IS NULL"))$n;
    expect_equal(nulls, 0L);

})

test_that("each VW-MIMAT-* view filters mimat to a single version", {

    views = grep("^vw-mimat-[0-9]+\\.[0-9]$",
                 DBI::dbListTables(con), value = TRUE);
    expect_true(length(views) > 0);

    for (v in views) {
        ## sanity: view has rows
        n = DBI::dbGetQuery(con,
                            sprintf("SELECT count(*) AS n FROM `%s`", v))$n;
        expect_true(n > 0,
                    info = sprintf("view %s is empty", v));

        ## all rows in the view share the same version, and that version
        ## matches the version embedded in the view name
        nv = DBI::dbGetQuery(con,
                             sprintf("SELECT count(DISTINCT version) AS n FROM `%s`", v))$n;
        expect_equal(nv, 1L,
                     info = sprintf("view %s spans more than one version", v));

        viewVersion = sub("^vw-mimat-", "", v);
        rowVersion = DBI::dbGetQuery(con,
                                     sprintf("SELECT DISTINCT version AS v FROM `%s`", v))$v;
        expect_equal(as.numeric(viewVersion), rowVersion,
                     info = sprintf("view %s reports version %s", v, rowVersion));
    }

})

test_that("sum of view row counts equals total mimat row count", {

    views = grep("^vw-mimat-[0-9]+\\.[0-9]$",
                 DBI::dbListTables(con), value = TRUE);

    perView = vapply(views,
                     function(v) DBI::dbGetQuery(con,
                                                 sprintf("SELECT count(*) AS n FROM `%s`", v))$n,
                     integer(1));
    total = DBI::dbGetQuery(con, "SELECT count(*) AS n FROM mimat")$n;

    expect_equal(sum(perView), total);

})

test_that("version table covers exactly the versions present in mimat", {

    vTbl = sort(DBI::dbGetQuery(con, "SELECT number FROM version")$number);
    vMimat = sort(unique(
        DBI::dbGetQuery(con, "SELECT DISTINCT version AS v FROM mimat")$v));

    expect_equal(vTbl, vMimat);

})

test_that("organism codes used in mimat overlap the organism dictionary", {

    ## Strict FK is not enforced and a small number of historical organism
    ## codes in mimat are absent from the organism table. Guard against
    ## *full* divergence (e.g. the dictionary being dropped in a rebuild).
    orgInDict = DBI::dbGetQuery(con,
        paste("SELECT count(DISTINCT organism) AS n FROM mimat",
              "WHERE organism IN (SELECT organism FROM organism)"))$n;
    orgTotal = DBI::dbGetQuery(con,
        "SELECT count(DISTINCT organism) AS n FROM mimat")$n;

    expect_true(orgInDict > 0);
    expect_true(orgInDict / orgTotal > 0.5,
                info = "less than half of mimat organism codes are in the organism dictionary");

})
