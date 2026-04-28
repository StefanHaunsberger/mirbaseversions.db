#
# Test select function implementation
#
# Author: Stefan Haunsberger
###############################################################################

require(miRBaseVersions.db);

context("select implementation");

test_that("select with keytype='MIMAT' returns one row per miRBase version", {

    res = select(miRBaseVersions.db,
                 keys = "MIMAT0000092",
                 keytype = "MIMAT",
                 columns = "*");

    expect_s3_class(res, "data.frame");
    expect_equal(colnames(res),
                 c("ACCESSION", "NAME", "SEQUENCE", "VERSION", "ORGANISM"));
    ## one row per release the accession appears in. The MIMAT keytype
    ## queries the base `mimat` table directly, so it does not include
    ## v22.1 — that release is exposed only as an alias view over v22.0.
    n_view_releases = sum(grepl("^VW-MIMAT-",
                                keytypes(miRBaseVersions.db)));
    expect_equal(nrow(res), n_view_releases - 1L);
    expect_true(all(res$ACCESSION == "MIMAT0000092"));
    expect_true(all(res$ORGANISM == "hsa"));
    ## newest release renamed to hsa-miR-92a-3p; oldest is hsa-miR-92
    expect_equal(res[res$VERSION == 22.0, "NAME"], "hsa-miR-92a-3p");
    expect_equal(res[res$VERSION == 6.0,  "NAME"], "hsa-miR-92");

});

test_that("select with non-existent key returns 0-row data frame with correct schema", {

    target = data.frame("ACCESSION" = character(),
                        "NAME"      = character(),
                        "SEQUENCE"  = character(),
                        "VERSION"   = numeric(),
                        "ORGANISM"  = character(),
                        check.names = TRUE,
                        stringsAsFactors = FALSE);

    expect_equal(select(miRBaseVersions.db,
                        keys = "MIMAT000092",
                        keytype = "MIMAT",
                        columns = "*"),
                 target);

});

test_that("select with invalid keytype errors", {

    expect_error(select(miRBaseVersions.db,
                        keys = "MIMAT0000092",
                        keytype = "IMAT",
                        columns = "*"),
                 "Keytype not valid");

});

test_that("select with version-specific view keytype returns one row", {

    res = select(miRBaseVersions.db,
                 keys = "MIMAT0000092",
                 keytype = "VW-MIMAT-22.0",
                 columns = "*");

    expect_equal(nrow(res), 1L);
    expect_equal(res$NAME, "hsa-miR-92a-3p");
    expect_equal(res$VERSION, 22.0);
    expect_equal(res$ORGANISM, "hsa");

});

test_that("select on VW-MIMAT-22.1 mirrors VW-MIMAT-22.0 with relabelled version", {

    ## v22.1 is an alias of v22.0. A query through the alias view should
    ## return identical accession/name/sequence/organism as v22.0 with the
    ## VERSION column relabelled to 22.1.
    r22  = select(miRBaseVersions.db, keys = "MIMAT0000092",
                  keytype = "VW-MIMAT-22.0", columns = "*");
    r221 = select(miRBaseVersions.db, keys = "MIMAT0000092",
                  keytype = "VW-MIMAT-22.1", columns = "*");

    expect_equal(nrow(r221), 1L);
    expect_equal(r221$VERSION, 22.1);
    expect_equal(r221$ACCESSION, r22$ACCESSION);
    expect_equal(r221$NAME,      r22$NAME);
    expect_equal(r221$SEQUENCE,  r22$SEQUENCE);
    expect_equal(r221$ORGANISM,  r22$ORGANISM);

});

test_that("select with column subset returns only requested columns", {

    res = select(miRBaseVersions.db,
                 keys = "MIMAT0000092",
                 keytype = "VW-MIMAT-22.0",
                 columns = c("ACCESSION", "NAME"));

    expect_equal(sort(colnames(res)), c("ACCESSION", "NAME"));
    expect_equal(nrow(res), 1L);

});

test_that("select is case-insensitive on keys", {

    upper = select(miRBaseVersions.db,
                   keys = "MIMAT0000092",
                   keytype = "VW-MIMAT-22.0",
                   columns = "*");
    lower = select(miRBaseVersions.db,
                   keys = "mimat0000092",
                   keytype = "VW-MIMAT-22.0",
                   columns = "*");

    expect_equal(upper, lower);

});

test_that("select with multiple keys returns rows for each", {

    res = select(miRBaseVersions.db,
                 keys = c("MIMAT0000001", "MIMAT0000092"),
                 keytype = "VW-MIMAT-22.0",
                 columns = c("ACCESSION", "ORGANISM"));

    expect_equal(nrow(res), 2L);
    expect_setequal(res$ACCESSION, c("MIMAT0000001", "MIMAT0000092"));
    expect_setequal(res$ORGANISM, c("cel", "hsa"));

});

test_that("select returns no rows for accession absent from older view", {

    ## MIMAT0035697 only appears from later releases — absent in v6.0
    res_old = select(miRBaseVersions.db,
                     keys = "MIMAT0035697",
                     keytype = "VW-MIMAT-6.0",
                     columns = "*");
    expect_equal(nrow(res_old), 0L);

});
