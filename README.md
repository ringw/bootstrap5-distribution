bootstrap5-distribution
#######################

Creates pretty bootstrap box plots from experiments with integer values and few
replicates (e.g. 3-5 RNAseq experimental replicates). Please read the
implications of this ggplot2 hack before sourcing it in a larger project.

Our goals for proprietary reports are as follows. Show the real median of the
replicates. Show a 2.5%ile, 25%ile, 75%ile, and 97.5%ile generated using
bootstrapping. Show extrema experimental replicates as outliers. Even though the
extrema out of 3 replicates are the 33%ile and the 67%ile, bootstrapping might
successfully tighten the 95% CI so that those individual replicates are shown to
be outliers, and we would like to show that that is the case.

One experimental condition at a time can use a callable function, such as a gene
set enrichment score. A large design can be graphed (multiple treatments,
certain timepoints of a time series). The confidence interval is useful to share
with collaborators, but this modification to the box plot could be unusual in
literature. The user should already start to run some statistical tests,
annotate ggplot2 with * and ** markers, and use the bootstrap findings for
guidance while narrowing down the figures to be published.
