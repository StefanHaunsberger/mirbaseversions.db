# TODO: Add comment
#
# Author: stefanhaunsberger
###############################################################################


require(ggplot2);
library(reshape2);	# For melt
require(dplyr);

#########################################################################

## Barchart for number of unique mature miRNAs among the releases/years

df = read.table(file.path("data-raw", "miRBase", "release-info.txt"), header = TRUE, stringsAsFactor = FALSE);
df$release.date = factor(df$release.date, levels = df$release);
df$version = factor(df$version, levels = df$version);
p = ggplot(df);

# g1 = ggplot(data=df, aes(x=version, y=mature.entries, group=1)) +
#     geom_line() +
#     geom_point(size=3) +
#     geom_text(aes(x = version, y = (mature.entries + 2000), label = release.date), color = "black", angle = 90, size=4) +
#     scale_y_continuous(expand = c(0,300), breaks = seq(0, (max(df$mature.entries) + 2500), by = 2500))
# print(g1)
# Add geom_bar layer
#	position="dodge": splitting up the bars
#	stat="identity": use own y values
#p = p + geom_bar(stat="identity", aes(x = release.date, y = mature.entries), position = "dodge");
p = p + geom_bar(stat="identity", aes(x = version, y = mature.entries), position = "dodge");
# Change axis labels
p = p + labs(x = "Version", y = "Number of mature miRNA entries", title = "Number of mature miRNA entries per miRBase release version")
# Reduce the space below zero and x-axis label
p = p + scale_y_continuous(expand = c(0,300), breaks = seq(0, (max(df$mature.entries) + 2500), by = 2500))
p = p + geom_text(aes(x = version, y = (mature.entries / 2), label = release.date), color = "white", angle = 90, size=6)
#p + geom_text(aes(x = version, y = 700, label = release.date), color = "white", angle = 90, size=3)
# dev.new();
# print(p);
# ggsave(filename = "entries-plot.png", plot = p, path = file.path("data-raw"),
#        dpi = 600
# );
# png(filename = file.path("data-raw", "entries-plot-new.png"),
#     width = 3240, height = 4500, res = 400)
# # print(p);
# print(p + theme(axis.text=element_text(size=12), axis.title=element_text(size=16), plot.title=element_text(size=16)))
# dev.off()
#
# tiff(file = file.path("data-raw", "entries-plot-new.tiff"), width = 3240, height = 4500, units = "px", res = 600)
# plot(p)
# dev.off()

p2 = p + theme(axis.text=element_text(size=14),
        axis.title=element_text(size=26),
        plot.title=element_text(size=27, hjust = -0.5));
dev.new();
png(filename = file.path("data-raw", "entries-plot-22022018-2.png"),
    width = 4000, height = 3200, res = 340)
plot(p2)
# print(p.sb);
dev.off()


# pdf("Rplots.pdf")
# print(p)
# dev.off()

#p + geom_text(aes(x = version, y = -1200, label = release.date), color = "black", angle = 45, size=3)

#########################################################################

## Barchar for differences between versions

# List files in directory
input.path = file.path("data-raw", "miRBase", "diff")
files = list.files(input.path, pattern = ".diff");

# Extract versions from filename and reorder
versions = substr(files, 1, sapply(gregexpr("\\.", files), tail, 1) - 1);
files = files[order(as.numeric(versions))];
versions = versions[order(as.numeric(versions))]

n.files = length(files);
# Initialize data frame for plotting (each file can have 4 different states {DELETE, NEW, SEQUENCE, NAME})
#df = data.frame(	version = character(),
#						change = character(),
#						number = integer(),
#						stringsAsFactors = FALSE);

df2 = data.frame(version = character(n.files),
                 delete = integer(n.files),
                 sequence = integer(n.files),
                 new = integer(n.files),
                 name = integer(n.files),
                 stringsAsFactors = FALSE);

# df3 = data_frame(version=numeric(), MIMAT=character(), miRNA=character(), Change=character());

max.sum = 0;
s = 0;
for (i in 1:n.files) {
    # Read all lines of this file
    l = readLines(file.path(input.path, files[i]));
    # Extract all MIMAT records
    mimats = l[grep("MIMAT", l)];
    if (length(mimats) > 0) {
        df2[i,] = c(	version = as.character(versions[i]),
                    delete = sum(grepl("\\tDELETE", mimats)),
                    sequence = sum(grepl("\\tSEQUENCE", mimats)),
                    new = sum(grepl("\\tNEW", mimats)),
                    name = sum(grepl("\\tNAME", mimats))
        );
#         ok <- TRUE
#         tryCatch(mimatsM <- {
#
#             matrix(unlist(strsplit(mimats, "\t")), ncol = 3, byrow = TRUE);
#
#         }, warning=function(w) {
#                      cat("problem values:", i, "\n")
#                      ok <<- FALSE
#                  }
#         )
#         if (!ok) break
        # mimatsM = matrix(unlist(strsplit(mimats, "\t")), ncol = 3, byrow = TRUE);
        # df3 = rbind(df3, data_frame(version=versions[i], MIMAT=mimatsM[,1], miRNA=mimatsM[,2], Change=mimatsM[,3]));

        #	s = df[i,] %>%
        #			select(new:name) %>%
        #			as.numeric() %>%
        #			sum();
        s = sum(as.numeric(df2[i,2:5]))
        if (s > max.sum) {
            max.sum = s;
        }
    }
}

df2 = df2[2:nrow(df2),]
df2$version = factor(df2$version, levels = df2$version)

df2.p = melt(df2, id.var="version");
df2.p$value = as.numeric(df2.p$value);

#### try overlay g1 plot
# g2 = ggplot(df.p, aes(x = version, y = value, fill = variable)) +
#     scale_fill_discrete(name = "Type of\nChange") +
#     geom_bar(stat = "identity") +
#     scale_y_continuous(breaks = seq(0, (max.sum + 250), by = 250)) +
#     labs(x = "Version", y = "Number of changes", title = "Grouped number of changes per miRBase version")

p.sb = ggplot(df2.p, aes(x = version, y = value, fill = variable)) +
    scale_fill_discrete(name = "Type of\nChange") +
    geom_bar(stat = "identity")
# Reduce the space below zero and x-axis label
#p.sb = p.sb + scale_y_continuous(expand = c(0,100))
# Change number of y-ticks (in steps of 250s)
p.sb = p.sb + scale_y_continuous(breaks = seq(0, (max.sum + 250), by = 500), expand = c(0,120));

p.sb = p.sb + labs(x = "Version", y = "Number of changes", title = "Grouped number of changes of mature miRNAs per miRBase version")


dev.new();
p.sb

# ggsave(filename = "diff-plot-new.png", plot = p.sb, path = file.path("data-raw"),
#        dpi = 400
# );
png(filename = file.path("data-raw", "diff-plot-22022018-1.png"),
    width = 4000, height = 4000, res = 400)
# print(p.sb);
dev.off()


print(p.sb + theme(axis.text=element_text(size=13),
                   axis.title=element_text(size=18),
                   plot.title=element_text(size=20),
                   legend.title=element_text(size=17),
                   legend.text=element_text(size=15)))
p.sb2 = p.sb + theme(axis.text=element_text(size=13),
                     axis.title=element_text(size=25),
                     plot.title=element_text(size=26, hjust = 0.3),
                     legend.title=element_text(size=24),
                     legend.text=element_text(size=21));
dev.new();
png(filename = file.path("data-raw", "diff-plot-22022018-2.png"),
    width = 4000, height = 3200, res = 340)
plot(p.sb2)
# print(p.sb);
dev.off()


dev.new();
tiff(file = file.path("data-raw", "diff-plot-new.tiff"), width = 4500, height = 4500, units = "px", res = 500)
plot(p.sb)
dev.off()

cs = colSums(as_data_frame(df2)[,2:5])
pie(colSums(as_data_frame(df2)[,2:5]), labels = paste(names(cs), cs))

df2.p %>% group_by(variable) %>% summarise(nChanges = sum(value))
