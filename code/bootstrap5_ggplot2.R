# Note: This script updates the prototype of the stat_boxplot function. It
# affects all ggplot2 boxplots for the duration of the R workspace, not limited
# to the stat call that is wrapped, e.g. update_stat_boxplot(stat_boxplot())
library(ggplot2)
custom_compute_group <- function (data, scales, width = NULL, na.rm = FALSE, coef = 1.5, 
          flipped_aes = FALSE) 
{
  data <- flip_data(data, flipped_aes)
  qs <- c(0, 0.25, 0.5, 0.75, 1)
  ci <- c(0.025, 0.975)
  if (!is.null(data$weight)) {
    mod <- quantreg::rq(y ~ 1, weights = weight, data = data, 
                        tau = qs)
    stats <- as.numeric(stats::coef(mod))
    mod <- quantreg::rq(y ~ 1, weights = weight, data = data, 
                        tau = ci)
    ci.stats <- as.numeric(stats::coef(mod))
  }
  else {
    stats <- as.numeric(stats::quantile(data$y, qs))
    ci.stats <- as.numeric(stats::quantile(data$y, ci))
  }
  names(stats) <- c("ymin", "lower", "middle", "upper", "ymax")
  outliers <- data$y < ci.stats[1] | data$y > ci.stats[2]
  if (any(outliers)) {
    stats[c(1, 5)] <- range(c(stats[2:4], data$y[!outliers]), 
                            na.rm = TRUE)
  }
  if (length(unique(data$x)) > 1) 
    width <- diff(range(data$x)) * 0.9
  df <- data.frame(as.list(stats))
  df$outliers <- list(data$y[outliers])
  if (is.null(data$weight)) {
    n <- sum(!is.na(data$y))
  }
  else {
    n <- sum(data$weight[!is.na(data$y) & !is.na(data$weight)])
  }
  df$notchupper <- ci[2]
  df$notchlower <- ci[1]
  df$x <- if (is.factor(data$x)) 
    data$x[1]
  else mean(range(data$x))
  df$width <- width
  df$relvarwidth <- sqrt(n)
  df$flipped_aes <- flipped_aes
  flip_data(df, flipped_aes)
}

update_stat_boxplot <- function(stat) {
  stat$stat$compute_group <- custom_compute_group;
  stat
}