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

    ## v22.1 is an alias of v22.0 (miRBase 22.1 only updated the
    ## high-confidence subset, which this package does not model) and
    ## therefore double-counts those rows when summed across views.
    ## Exclude it from the row-conservation check.
    views = grep("^vw-mimat-[0-9]+\\.[0-9]$",
                 DBI::dbListTables(con), value = TRUE);
    views = setdiff(views, "vw-mimat-22.1");

    perView = vapply(views,
                     function(v) DBI::dbGetQuery(con,
                                                 sprintf("SELECT count(*) AS n FROM `%s`", v))$n,
                     integer(1));
    total = DBI::dbGetQuery(con, "SELECT count(*) AS n FROM mimat")$n;

    expect_equal(sum(perView), total);

})

test_that("vw-mimat-22.1 is a row-for-row alias of vw-mimat-22.0", {

    ## miRBase 22.1 only changed the high-confidence subset; sequences,
    ## accessions and names are unchanged from 22.0. The v22.1 view is
    ## defined as a relabelled select over v22.0 rows.
    n22  = DBI::dbGetQuery(con, "SELECT count(*) AS n FROM `vw-mimat-22.0`")$n;
    n221 = DBI::dbGetQuery(con, "SELECT count(*) AS n FROM `vw-mimat-22.1`")$n;
    expect_equal(n221, n22);

    diff_count = DBI::dbGetQuery(con, paste(
        "SELECT count(*) AS n FROM (",
        "  SELECT accession, name, sequence, organism FROM `vw-mimat-22.0`",
        "  EXCEPT",
        "  SELECT accession, name, sequence, organism FROM `vw-mimat-22.1`",
        ")"))$n;
    expect_equal(diff_count, 0L);

})

test_that("version table covers exactly the versions present in mimat (plus alias releases)", {

    vTbl = sort(DBI::dbGetQuery(con, "SELECT number FROM version")$number);
    vMimat = sort(unique(
        DBI::dbGetQuery(con, "SELECT DISTINCT version AS v FROM mimat")$v));

    ## v22.1 is registered in `version` but exists only as an alias view over
    ## v22.0 (no rows in `mimat`). All other entries must align.
    expect_equal(setdiff(vTbl, vMimat), 22.1);
    expect_equal(setdiff(vMimat, vTbl), numeric(0));

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
