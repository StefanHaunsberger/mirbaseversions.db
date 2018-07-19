
# miRBaseVersions.db

The _miRBaseVersions.db_ R package has been developed to provide an easy accessible repository for several different miRBase release versions ([miRBase](http://www.mirbase.org)).
It contains 22 different miRBase release versions and implements the `select` interface.

* [Introduction](#introduction)
* [Use Cases](#use-cases)
   - [Function `keytypes`](#function-keytypes)
   - [Function `columns`](#function-columns)
   - [Function `keys`](#function-keys)
   - [Function `select`](#function-select)
* [Additional Information](#additional-information)

## Please support this work

If you make use of this package, please cite the following 'OpenAccess' publication to allow us to keep the package up to date:

> Haunsberger SJ, Connolly NMC and Prehn JHM* (2016). “miRNAmeConverter: an R/Bioconductor package for translating mature miRNA names to different miRBase versions.” Bioinformatics. doi: <a href="https://academic.oup.com/bioinformatics/article/33/4/592/2606064" target="_blank">10.1093/bioinformatics/btw660</a>.


## Introduction

The _miRBaseVersions.db_ package is an annotation package which includes 
mature miRNA names from 22 miRBase release versions. Due to ongoing growth and 
changes with each release miRNA names can have different names in different 
versions or even are not listed as valid miRNAs anymore. This annotation package
serves as a repository and can be used for quick lookup for mature miRNA names. 
The _miRBaseVersions.db_ package has implemented the AnnotationDbi-select 
interface. By implementing this `select` interface the user is able to use 
the same methods as for any other annotation package.

The main four implemented methods are 

- `columns`, presents the values one can retrieve in the final result,
- `keytypes`, which presents the tables that can be used in this package,
- `keys`, is used to get viable keys of a particular `keytype` and
- `select`, which is used to extract data from the annotation package by using 
values provided by the other three methods.

To load the package and gain access to the functions just run the 
following command:

```r
> library(miRBaseVersions.db)
```

### Database information

The data is the _miRNAmeConverter_ package is stored in an SQLite database. All entries contained in the database were downloaded from the
<a href="http://www.mirbase.org/ftp.shtml" target="_blank">miRBase ftp-site</a>. The following versions are available:


|miRBase Version |Release Date	  | # Mature entries|
|---------------:|---------------:|----------------:|
|	6.0	         |	04/05         |	1650	        |
|	7.1	         |	10/05         |	3424	        |
|	8.0	         |	02/06         |	3518	        |
|	8.1	         |	05/06         |	3963	        |
|	8.2	         |	07/06         |	4039	        |
|	9.0	         |	10/06         |	4361	        |
|	9.1	         |	02/07         |	4449	        |
|	9.2	         |	05/07         |	4584	        |
|	10.0         |	08/07         |	5071	        |
|	10.1         |	12/07         |	5395	        |
|	11.0         |	04/08         |	6396	        |
|	12.0         |	09/08         |	8619	        |
|	13.0         |	03/09         |	9539	        |
|	14.0         |	09/09         |	10883	        |
|	15.0         |	04/10         |	14197	        |
|	16.0         |	08/10         |	15172	        |
|	17.0         |	04/11         |	16772	        |
|	18.0         |	11/11         |	18226	        |
|	19.0         |	08/12         |	21264	        |
|	20.0         |	06/13         |	24521	        |
|	21.0         |	06/14         |	28645	        |
|	22.0         |	03/18         |	38589	        |


from 271 organisms.

## Use Cases

### Function `keytypes`

Use this function to receive table names from where data can be retrieved:
```r
> keytypes(miRBaseVersions.db)
 [1] "MIMAT"         "VW-MIMAT-10.0" "VW-MIMAT-10.1" "VW-MIMAT-11.0" "VW-MIMAT-12.0"
 [6] "VW-MIMAT-13.0" "VW-MIMAT-14.0" "VW-MIMAT-15.0" "VW-MIMAT-16.0" "VW-MIMAT-17.0"
[11] "VW-MIMAT-18.0" "VW-MIMAT-19.0" "VW-MIMAT-20.0" "VW-MIMAT-21.0" "VW-MIMAT-22.0"
[16] "VW-MIMAT-6.0"  "VW-MIMAT-7.1"  "VW-MIMAT-8.0"  "VW-MIMAT-8.1"  "VW-MIMAT-8.2" 
[21] "VW-MIMAT-9.0"  "VW-MIMAT-9.1"  "VW-MIMAT-9.2"
```
The keytype "MIMAT" is the main table containing all
records from all supported miRBase release versions. Keytypes starting with 
the prefix "VW-MIMAT" are so called SQL views. For example the keytype
"VW-MIMAT-22.0" is an SQL view from the "MIMAT" table which only holds records
from miRBase version 22.0.

### Function `columns`

Use the `columns` function to retreive information about the kind of variables
you can retrieve in the final output:
```r
> columns(miRBaseVersions.db)
[1] "ACCESSION" "NAME"      "ORGANISM"  "SEQUENCE"  "VERSION"  
```
All columns are available for all keytypes.

### Function `keys`

The `keys` function returns all viable keys of a praticular `keytype`. The 
following example retrieves all possible keys for miRBase release version 6.0.
```r
> head(keys(miRBaseVersions.db, keytype = "VW-MIMAT-6.0"))
[1] "MIMAT0000001" "MIMAT0000002" "MIMAT0000003" "MIMAT0000004" "MIMAT0000005" "MIMAT0000006"
```

### Function `select`

The `select` function is used to extract data. As input values the function
takes outputs received from the other three functions `keys`, 
`columns` and `keytypes`.  
For exmaple to extract all information about the mature 
accession 'MIMAT0000092' we can run the following command:
```r
> result = select(miRBaseVersions.db, 
                keys = "MIMAT0000092", 
                keytype = "MIMAT", 
                columns = "*")
> head(result)
     ACCESSION           NAME               SEQUENCE VERSION ORGANISM
1 MIMAT0000092 hsa-miR-92a-3p UAUUGCACUUGUCCCGGCCUGU      22      hsa
2 MIMAT0000092 hsa-miR-92a-3p UAUUGCACUUGUCCCGGCCUGU      21      hsa
3 MIMAT0000092 hsa-miR-92a-3p UAUUGCACUUGUCCCGGCCUGU      20      hsa
4 MIMAT0000092 hsa-miR-92a-3p UAUUGCACUUGUCCCGGCCUGU      19      hsa
5 MIMAT0000092 hsa-miR-92a-3p UAUUGCACUUGUCCCGGCCUGU      18      hsa
6 MIMAT0000092    hsa-miR-92a UAUUGCACUUGUCCCGGCCUGU      17      hsa
```
As we can see the result returns all miRNA names the accession had among the different miRBase releases. If we for example only want to extract the fields for 'accession', 'name' and 'version' we simply run the following command:
```r
> result = select(miRBaseVersions.db, 
                keys = "MIMAT0000092", 
                keytype = "MIMAT", 
                columns = c("ACCESSION", "NAME", "VERSION"))
> result
     ACCESSION           NAME VERSION
1 MIMAT0000092 hsa-miR-92a-3p      22
2 MIMAT0000092 hsa-miR-92a-3p      21
3 MIMAT0000092 hsa-miR-92a-3p      20
4 MIMAT0000092 hsa-miR-92a-3p      19
5 MIMAT0000092 hsa-miR-92a-3p      18
6 MIMAT0000092    hsa-miR-92a      17
```
In comparison to the previous output with parameter `columns = "*"` this time
only the selected columns were returned.

## Additional information

### Packages loaded via namespace
The following packages are used in the `miRBaseVersions.db` package: 

* AnnotationDbi_1.32.3
* DBI_0.3.1 <a href="http://CRAN.R-project.org/package=RSQLite" target="_blank">visit on CARN</a>
* RSQLite_1.0.0 <a href="http://CRAN.R-project.org/package=DBI" target="_blank">visit on CARN</a>
* gtools_3.5.0 <a href="https://CRAN.R-project.org/package=gtools" target="_blank">visit on CARN</a>

### Future Aspects
This database can only be of good use if it will be kept up to date.
Therefore, please cite our work to allow us to keep this tool up to date!
