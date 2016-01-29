# TODO: Add comment
#
# Author: stefanhaunsberger
###############################################################################


#require(miRNAmeConverter);

#nc = MiRNANameConverter();
# Read names
d = read.table(file = file.path("tests/testthat/names.txt"), header = TRUE, stringsAsFactor = FALSE);
# Extract miRNA names (without assay id)
example.miRNAs = substr(d$miRNA, 1, sapply(gregexpr("-", d$miRNA), tail, 1) - 1);
rm(d);
save(example.miRNAs, file = "data/example-miRNAs.rdata")
