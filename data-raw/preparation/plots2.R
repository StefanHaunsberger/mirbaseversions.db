grid.newpage()
# p1<-ggplot(data=df2.p, aes(x=Date, weight=Percent, colour=Pop, fill=Pop))+
#     geom_bar(position=position_dodge())+
p1 <- ggplot(df2.p, aes(x = version, y = value, fill = variable)) +
    scale_fill_discrete(name = "Type of\nChange") +
    geom_bar(stat = "identity") +
    theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5))+
    labs(x = "Version", y = "Number of unique miRNA entries", title = "Unique miRNA entries among release versions")+
    theme_bw()+
    theme(legend.justification=c(0,1),
          legend.position=c(0,1),
          plot.title=element_text(size=30,vjust=1),
          axis.text.x=element_text(size=20),
          axis.text.y=element_text(size=20),
          axis.title.x=element_text(size=20),
          axis.title.y=element_text(size=20))
# p2<-ggplot()+geom_line(data=df,
#                        aes(x=Date, y=min_temp), color="red")+
p2 <- ggplot(data=df, aes(x=version, y=mature.entries, group=1)) +
    geom_line() +
    geom_point(size=3) +
    geom_text(aes(x = version, y = (mature.entries + 2000), label = release.date), color = "black", angle = 90, size=4)+
    # geom_hline(yintercept=12.5, color="forestgreen")+
    theme_bw() %+replace%
    theme(panel.background = element_rect(fill = NA),
          panel.grid.major.x=element_blank(),
          panel.grid.minor.x=element_blank(),
          panel.grid.major.y=element_blank(),
          panel.grid.minor.y=element_blank(),
          axis.text.y=element_text(size=20,color="black"),
          axis.title.y=element_text(size=20))

g1<-ggplot_gtable(ggplot_build(p1))
g2<-ggplot_gtable(ggplot_build(p2))

pp<-c(subset(g1$layout,name=="panel",se=t:r))
g<-gtable_add_grob(g1, g2$grobs[[which(g2$layout$name=="panel")]],pp$t,pp$l,pp$b,pp$l)

ia<-which(g2$layout$name=="axis-l")
ga <- g2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(1, "npc") + unit(0.15, "cm")
g <- gtable_add_cols(g, g2$widths[g2$layout[ia, ]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)

grid.draw(g)
