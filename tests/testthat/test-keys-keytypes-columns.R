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
        "VW-MIMAT-20.0", "VW-MIMAT-21.0", "VW-MIMAT-22.0", "VW-MIMAT-6.0",
        "VW-MIMAT-7.1", "VW-MIMAT-8.0", "VW-MIMAT-8.1",  "VW-MIMAT-8.2",
        "VW-MIMAT-9.0", "VW-MIMAT-9.1", "VW-MIMAT-9.2"
    );

    expect_equal(keytypes(miRBaseVersions.db), target);

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



