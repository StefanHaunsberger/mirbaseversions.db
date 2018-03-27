
# miRBaseVersions.db

The _miRBaseVersions.db_ R package has been developed to provide an easy accessible repository for several different miRBase release versions ([miRBase](http://www.mirbase.org)).
It contains 22 different miRBase release versions and implements the `select` interface.

* [Introduction](#introduction)
* [Use Cases](#use-cases)
   - [Function `keytypes`](#keytypes)
   - [Function `columns`](#cols)
   - [Function `keys`](#keys)
   - [Function `select`](#sel)
* [Additional Information](#info)

##Introduction

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

```{r highlight = TRUE}
library(miRBaseVersions.db)
```

###Database information

The data is the _miRNAmeConverter_ package is stored in an SQLite database. All entries contained in the database were downloaded from the [miRBase ftp-site](ftp://mirbase.org/pub/mirbase/). The following versions are available:


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

##Use Cases

### <a name="#keytypes"></a>Function `keytypes`

Use this function to receive table names from where data can be retrieved:
```{r highlight=TRUE}
keytypes(miRBaseVersions.db);
```
The output lists `r length(keytypes(miRBaseVersions.db))` tables where each one
of them can be queried. The keytype "MIMAT" is the main table containing all
records from all supported miRBase release versions. Keytypes starting with 
the prefix "VW-MIMAT" are so called SQL views. For example the keytype
"VW-MIMAT-22.0" is an SQL view from the "MIMAT" table which only holds records
from miRBase version 22.0.

### <a name="#cols"></a>Function `columns`

Use the `columns` function to retreive information about the kind of variables
you can retrieve in the final output:
```{r highlight=TRUE}
columns(miRBaseVersions.db);
```
All `r length(columns(miRBaseVersions.db))` columns are available for all 
`r length(keytypes(miRBaseVersions.db))` keytypes.

### <a name="#keys"></a>Function `keys`

The `keys` function returns all viable keys of a praticular `keytype`. The 
following example retrieves all possible keys for miRBase release version 6.0.
```{r highlight=TRUE}
k = head(keys(miRBaseVersions.db, keytype = "VW-MIMAT-6.0"));
k;
```

### <a name="#sel"></a>Function `select`

The `select` function is used to extract data. As input values the function
takes outputs received from the other three functions `keys`, 
`columns` and `keytypes`.  
For exmaple to extract all information about the mature 
accession 'MIMAT0000092' we can run the following command:
```{r highlight=TRUE}
result = select(miRBaseVersions.db, 
                keys = "MIMAT0000092", 
                keytype = "MIMAT", 
                columns = "*")
result;
```
As we can see the result returns all miRNA names the accession had among the
different miRBase releases.
If we for example only want to extract the fields for 'accession', 'name' and 
'version' we simply run the following command:
```{r highlight=TRUE}
result = select(miRBaseVersions.db, 
                keys = "MIMAT0000092", 
                keytype = "MIMAT", 
                columns = c("ACCESSION", "NAME", "VERSION"))
result;
```
In comparison to the previous output with parameter `columns = "*"` this time
only the selected columns were returned.

## <a name="#info"></a>Additional information

### Packages loaded via namespace
The following packages are used in the `miRBaseVersions.db` package: 

* AnnotationDbi_1.32.3 [@annotationdbicite]
* DBI_0.3.1 [@dbicite]
* RSQLite_1.0.0 [@rsqlitecite]
* gtools_3.5.0 [@gtoolscite]

### Future Aspects
This database can only be of good use if it will be kept up to date.
Therefore we plan to include new miRBase releases as soon as possible.
