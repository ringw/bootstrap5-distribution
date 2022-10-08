library(airway)
data(airway)
library(ggplot2)

# Bar plot of read counts mapped to a single gene is rarely useful. You should
# normally use a gene set enrichment statistic as your lambda function. This is
# a trivial example of a single box plot.
airway_gene <- assay(airway['ENSG00000103196', ])
dist <- bootstrap5_distribution(airway_gene, function(x) x)
ggplot(data.frame(count=dist)) + aes(y=count, main="Read counts of gene") + update_stat_boxplot(stat_boxplot()) + geom_boxplot()
