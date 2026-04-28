#
# Test three functions (keytypes, keys and columns) from the
# AnnotationDBI select interface implementation
#
# Author: Stefan Haunsberger
###############################################################################

require(miRBaseVersions.db);

context("keys, keytypes and columns function");

test_that("Function: keytypes", {

    target = c(
        "MIMAT", "VW-MIMAT-10.0", "VW-MIMAT-10.1", "VW-MIMAT-11.0",
        "VW-MIMAT-12.0", "VW-MIMAT-13.0", "VW-MIMAT-14.0", "VW-MIMAT-15.0",
        "VW-MIMAT-16.0", "VW-MIMAT-17.0", "VW-MIMAT-18.0", "VW-MIMAT-19.0",
        "VW-MIMAT-20.0", "VW-MIMAT-21.0", "VW-MIMAT-22.0", "VW-MIMAT-22.1",
        "VW-MIMAT-6.0", "VW-MIMAT-7.1",  "VW-MIMAT-8.0",  "VW-MIMAT-8.1",
        "VW-MIMAT-8.2", "VW-MIMAT-9.0",  "VW-MIMAT-9.1",  "VW-MIMAT-9.2"
    );

    expect_equal(keytypes(miRBaseVersions.db), target);

})

test_that("keytypes contains MIMAT plus one VW-MIMAT-* entry per release", {

    kt = keytypes(miRBaseVersions.db);
    views = grep("^VW-MIMAT-", kt, value = TRUE);

    expect_true("MIMAT" %in% kt);
    ## one base table + N version views, no duplicates
    expect_equal(length(kt), length(views) + 1L);
    expect_equal(length(unique(kt)), length(kt));

})

test_that("Function: columns", {

    target = c(
                "ACCESSION",
                "NAME",
                "ORGANISM",
                "SEQUENCE",
                "VERSION"
                );
    expect_equal(columns(miRBaseVersions.db), target);

})

test_that("columns are uppercase", {

    cols = columns(miRBaseVersions.db);
    expect_equal(cols, toupper(cols));

})

test_that("Function: keys - 20 to 25 keytype='VW-MIMAT-16.0'", {

    target = c(
        "MIMAT0000020", "MIMAT0000021", "MIMAT0000022",
        "MIMAT0000023", "MIMAT0000024", "MIMAT0000025"
    );
    expect_equal(keys(miRBaseVersions.db, "VW-MIMAT-16.0")[20:25], target);

})

test_that("Function: keys - 500 to 505 keytype='MIMAT'", {

    target = c(
        "MIMAT0000525", "MIMAT0000526", "MIMAT0000527",
        "MIMAT0000528", "MIMAT0000529", "MIMAT0000530"
    );
    expect_equal(keys(miRBaseVersions.db, "MIMAT")[500:505], target);

})

test_that("keys returns a non-empty character vector for every keytype", {

    for (kt in keytypes(miRBaseVersions.db)) {
        k = keys(miRBaseVersions.db, kt);
        expect_type(k, "character");
        expect_true(length(k) > 0L,
                    info = sprintf("keytype %s returned no keys", kt));
    }

})

test_that("keys size grows monotonically across miRBase releases", {

    versions = c("6.0", "7.1", "8.0", "8.1", "8.2",
                 "9.0", "9.1", "9.2", "10.0", "10.1",
                 "11.0", "12.0", "13.0", "14.0", "15.0",
                 "16.0", "17.0", "18.0", "19.0", "20.0",
                 "21.0", "22.0", "22.1");
    sizes = vapply(versions,
                   function(v) length(keys(miRBaseVersions.db,
                                           paste0("VW-MIMAT-", v))),
                   integer(1));
    ## non-decreasing — accessions only accumulate across releases
    expect_true(all(diff(sizes) >= 0));
    ## the latest release is at least as large as every prior release.
    ## v22.1 ties v22.0 (alias view: same rows, same count) so use max-equal
    ## rather than strict which.max identity.
    expect_equal(unname(sizes[length(sizes)]), max(sizes));

})

test_that("keys for unknown keytype errors", {

    expect_error(keys(miRBaseVersions.db, "VW-MIMAT-99.0"),
                 "does not exist");

})
