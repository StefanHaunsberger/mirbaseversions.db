
library(AnnotationDbi)

# mirbasenames_dbconn <- function() AnnotationDbi::dbconn(datacache)
# mirbasenames_dbfile <- function() AnnotationDbi::dbfile(datacache)

.MiRBaseNamesDb = setRefClass(
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

# .cols <- function(this)
# {
#     con <- AnnotationDbi::dbconn(this)
#     list <- dbListTables(con)
#     ## drop unwanted tables
#     unwanted <- c("map_counts","map_metadata","metadata")
#     list <- list[!list %in% unwanted]
#     ## Then just to format things in the usual way
#     list <- toupper(list)
#     dbDisconnect(con)
#     list
# }

#' Get column names
.getLCColnames = function(this) {
    # Retrieve tables names from database
    list = dbListTables(mirbasenames_dbconn())
    ## drop unwanted tables
    unwanted <- c("map_counts",
                  "map_metadata",
                  "metadata",
                  "vw.+",
                  "taqman",
                  "\\bmi\\b", # Only 'mi' matches but not 'mimat'
                  "mi2mimat");
    cols = grep(paste(unwanted, collapse = "|"),
                dbListTables(mirbasenames_dbconn()),
                value = TRUE, invert = TRUE);
    return(cols);
}

setMethod(
    f = "columns",
    signature = "MiRBaseNamesDb",
    # definition = .cols(this)
    definition = function(this) {
#         # con <- AnnotationDbi::dbconn(this);
#         # list <- dbListTables(con);
#         list = dbListTables(mirbasenames_dbconn())
#         ## drop unwanted tables
#         unwanted <- c("map_counts",
#                       "map_metadata",
#                       "metadata",
#                       "vw.+",
#                       "taqman",
#                       "mi",
#                       "mi2mimat");
#         cols = grep(paste(unwanted, collapse = "|"),
#                     dbListTables(mirbasenames_dbconn()),
#                     value = TRUE, invert = TRUE);
#         ## Then just to format things in the usual way
#         cols <- toupper(cols);
#         # dbDisconnect(con);
#         cols;
        cols = .getLCColnames(this);
        return(toupper(cols));
    }
)
