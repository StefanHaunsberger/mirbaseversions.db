#
# Test select function implementation
#
# Author: Stefan Haunsberger
###############################################################################

require(miRBaseVersions.db);

context("select implementation");

test_that("Test 1: select MIMAT00000092 with all columns (*)", {

    target = read.table(file.path("select-test1.txt"),
                        stringsAsFactors = FALSE);

    is_equivalent_to(select(miRBaseVersions.db,
                        keys = "MIMAT0000092",
                        keytype = "MIMAT",
                        columns = "*"),
                 target);

});

test_that("Test 2: select not existing MIMAT", {

    target = data.frame("ACCESSION" = character(),
                        "NAME" = character(),
                        "SEQUENCE" = character(),
                        "VERSION" = numeric(),
                        "ORGANISM" = character(),
                        check.names = TRUE,
                        stringsAsFactors = FALSE)

    expect_equal(select(miRBaseVersions.db,
                        keys = "MIMAT000092",
                        keytype = "MIMAT",
                        columns = "*"),
                 target);

});


test_that("Test 3: select with not valid keytype", {

    expect_error(select(miRBaseVersions.db,
                        keys = "MIMAT0000092",
                        keytype = "IMAT",
                        columns = "*"),
                 "Keytype not valid");

});



