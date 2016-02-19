## ----highlight = FALSE, echo=FALSE, results='hide'-----------------------
suppressPackageStartupMessages(require(AnnotationDbi))

## ----highlight = TRUE----------------------------------------------------
library(miRBaseVersions.db)

## ----highlight=TRUE------------------------------------------------------
keytypes(miRBaseVersions.db);

## ----highlight=TRUE------------------------------------------------------
columns(miRBaseVersions.db);

## ----highlight=TRUE------------------------------------------------------
k = head(keys(miRBaseVersions.db, keytype = "VW-MIMAT-6.0"));
k;

## ----highlight=TRUE------------------------------------------------------
result = select(miRBaseVersions.db, 
                keys = "MIMAT0000092", 
                keytype = "MIMAT", 
                columns = "*")
result;

## ----highlight=TRUE------------------------------------------------------
result = select(miRBaseVersions.db, 
                keys = "MIMAT0000092", 
                keytype = "MIMAT", 
                columns = c("ACCESSION", "NAME", "VERSION"))
result;

