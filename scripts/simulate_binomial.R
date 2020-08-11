source('scripts/settings.R')
#' Simulate bernoulli strings of length n with success probability p
#' and store strings with their sums in a data frame.

#' Initialize
n <- 12
p <- 1/12
L <- 5e4
bi_sim <- data.frame(string = character(),
                     sum = numeric(),
                     stringsAsFactors = F)
set.seed(123)
#' Populate data frame
#' for loops are SLOW in R so this will run slowly (on purpose)
for(i in 1:L) {
  string <- rbinom(n, 1, p)
  bi_sim[i, 1] <- paste(as.character(string), collapse = '')
  bi_sim[i, 2] <- sum(string)
  if (i %% 1000 == 0) {
    print(i)
  }
}

# Export data 
write_csv(x = bi_sim, path = 'data/binom_sim.csv')
