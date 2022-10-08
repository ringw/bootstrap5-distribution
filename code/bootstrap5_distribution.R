library(testit)

# Bootstrap for box plot, for experiment with few replicates (at most 5). We
# produce a fixed-size result, and we want to plot every extreme experimental
# replicate. If the matrix has more columns (replicates), then the function
# would fail. If you have 7+ experimental replicates, then you shouldn't need
# a result that includes the median and extreme replicates treated individually.
# You should use a standard bootstrap such as the "boot" package in that case.
#
# The result should only be used via:
# quantile(b, c(0, 0.025, 0.25, 0.5, 0.75, 0.975, 1))
# Extrema are each unique value below 0.025% or above 0.975%. Median data is
# currently always rewritten to show the median original replicate. All other
# quantiles shown are the bootstrap quantiles (confidence interval).
bootstrap5_distribution <- function(matrix, fn, niter = 200) {
  if (length(colnames(matrix)) > 0) repnames <- colnames(matrix)
  else repnames <- 1:ncol(matrix)
  # Collect scalar simulations of each experimental replicate: The matrix should
  # hold integer values, so we simulate and produce a scalar by using a Poisson
  # random variable.
  values <- apply(
    matrix,
    2,
    function(col)
      sapply(1:niter, function(i) fn(rpois(length(col), col))))
  # Collect the lambda function applied to each experimental replicate.
  values.actual <- apply(
    matrix,
    2,
    fn
  )
  colnames(values) <- repnames
  names(values.actual) <- repnames
  reps <- repnames[order(values.actual)]
  
  bootstrap_orig <- sapply(
    1:1001,
    function(i)
      mean(
      values[sample(1:nrow(values), length(reps), TRUE),
             sample(1:ncol(values), length(reps), TRUE)]));
  quantiles <- 0:200 / 200.

  dist <- quantile(bootstrap_orig, quantiles)
  # 25%ile and 75%ile from bootstrap. Everything in between (to capture 50%ile):
  # real median without Poisson resampling.
  dist[52:150] <- (
    if (length(repnames) %% 2 == 1)
      values.actual[reps[3]]
    else
      quantile(values.actual, 0.5)
  )
  
  # Extrema from real extreme replicates, not Poisson resampling.
  dist[1:5] = dist[6] # Copy 2.5%ile to lower extrema.
  dist[197:201] = dist[196] # Copy 97.5%ile to higher extrema.
  low_extreme_index = 1
  for (rep in reps) {
    if (values.actual[rep] > dist[low_extreme_index])
      break
    assert("Too many replicates to display outlier experimental replicates",
           low_extreme_index < 6)
    dist[low_extreme_index] = values.actual[rep]
    low_extreme_index <- low_extreme_index + 1
  }
  high_extreme_index = 201
  for (rep in rev(reps)) {
    if (values.actual[rep] < dist[high_extreme_index])
      break
    assert("Too many replicates to display outlier experimental replicates",
           high_extreme_index > 196)
    dist[high_extreme_index] = values.actual[rep]
    high_extreme_index <- high_extreme_index - 1
  }
  dist
}
