# miRBaseVersions.db

A Bioconductor-style annotation R package shipping mature miRNA names from
**23 miRBase release versions** (6.0 through 22.1). Exposed through the
standard `AnnotationDbi` `select` interface so it plugs in alongside any
other annotation package.

Use it to translate or reconcile mature miRNA accessions and names across
miRBase versions — e.g. mapping a legacy `MIMAT` accession to its current
v22.1 name, or pulling the full per-version naming history of a miRNA.

## Installation

```r
# install.packages("BiocManager")
BiocManager::install("AnnotationDbi")          # required dependency

# install miRBaseVersions.db from source
# R CMD INSTALL miRBaseVersions.db
```

Runtime dependencies: `AnnotationDbi`, `DBI`, `RSQLite`, `methods`, `gtools`.

## Quick start

```r
library(miRBaseVersions.db)

# What can I query?
keytypes(miRBaseVersions.db)
#>  [1] "MIMAT"        "VW-MIMAT-22.1" "VW-MIMAT-22.0" ... "VW-MIMAT-6.0"

columns(miRBaseVersions.db)
#> [1] "ACCESSION" "NAME" "ORGANISM" "SEQUENCE" "VERSION"

# Full naming history of one mature miRNA across every release
select(miRBaseVersions.db,
       keys    = "MIMAT0000092",
       keytype = "MIMAT",
       columns = c("ACCESSION", "NAME", "VERSION"))

# Just the names present in the current release
keys(miRBaseVersions.db, keytype = "VW-MIMAT-22.1")[1:5]
```

The `MIMAT` keytype searches across every version. Each `VW-MIMAT-<X.Y>`
keytype is a per-release SQL view that filters down to one version.

## Versions covered

| miRBase version | Mature entries | Released |
|----------------:|---------------:|---------:|
| 6.0  |  1,591 | 04/05 |
| 7.1  |  3,101 | 10/05 |
| 8.0  |  3,228 | 02/06 |
| 8.1  |  3,684 | 05/06 |
| 8.2  |  3,834 | 07/06 |
| 9.0  |  4,167 | 10/06 |
| 9.1  |  4,274 | 02/07 |
| 9.2  |  4,430 | 05/07 |
| 10.0 |  5,395 | 08/07 |
| 10.1 |  5,718 | 12/07 |
| 11.0 |  6,703 | 04/08 |
| 12.0 |  9,110 | 09/08 |
| 13.0 | 10,097 | 03/09 |
| 14.0 | 11,663 | 09/09 |
| 15.0 | 15,632 | 04/10 |
| 16.0 | 17,341 | 08/10 |
| 17.0 | 19,724 | 04/11 |
| 18.0 | 21,643 | 11/11 |
| 19.0 | 25,141 | 08/12 |
| 20.0 | 30,424 | 06/13 |
| 21.0 | 35,828 | 06/14 |
| 22.0 | 48,885 | 03/18 |
| 22.1 | 48,885 | 10/18 |

277 organisms in total.

**Note on v22.1.** miRBase 22.1 only updated the high-confidence subset
(which this package does not model); sequences, accessions and names are
unchanged from v22.0. The `VW-MIMAT-22.1` keytype is therefore a
relabelled alias view over `VW-MIMAT-22.0` rather than a separately
ingested release. Querying it yields the same rows as v22.0 with
`VERSION = 22.1`.

## Documentation

A worked-examples vignette is included with the package:

```r
vignette("miRBaseVersions.db-vignette")
```

## License

Artistic-2.0
