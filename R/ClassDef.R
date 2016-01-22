
library(AnnotationDbi)

# mirbasenames_dbconn <- function() AnnotationDbi::dbconn(datacache)
# mirbasenames_dbfile <- function() AnnotationDbi::dbfile(datacache)

MiRBaseNamesDb = setRefClass(
    Class = "MiRBaseNamesDb",

#     slots = representation(
#         name = "character"
#     ),
#
#     prototype = list(
#         name = "testMiRBaseNamesDb"
#     ),
    contains = "AnnotationDb"

)
