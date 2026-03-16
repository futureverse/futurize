if (requireNamespace("sva") && requireNamespace("doFuture")) {
library(futurize)
library(sva)
print(sessionInfo())

options(future.rng.onMisuse = "error")

plan(multisession)

## Create simple test data for ComBat
set.seed(42)
n_genes <- 50L
n_samples <- 20L
dat <- matrix(rnorm(n_genes * n_samples), nrow = n_genes, ncol = n_samples)
rownames(dat) <- paste0("gene", seq_len(n_genes))
colnames(dat) <- paste0("sample", seq_len(n_samples))

## Add batch effect
batch <- rep(c(1, 2), each = n_samples / 2L)
dat[, batch == 2] <- dat[, batch == 2] + 2


## ---------------------------------------------------------
## ComBat()
## ---------------------------------------------------------
set.seed(42)
result_truth <- ComBat(dat = dat, batch = batch)
str(result_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
result <- ComBat(dat = dat, batch = batch) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
str(result)
stopifnot(all.equal(result, result_truth))

set.seed(42)
counters <- plan("backend")[["counters"]]
result2 <- sva::ComBat(dat = dat, batch = batch) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(result2, result_truth))


## ---------------------------------------------------------
## ComBat() with mod
## ---------------------------------------------------------
## Covariate must not be confounded with batch
group <- rep(c("A", "B"), times = n_samples / 2L)
mod <- model.matrix(~ group)

set.seed(42)
result_truth <- ComBat(dat = dat, batch = batch, mod = mod)
str(result_truth)

set.seed(42)
counters <- plan("backend")[["counters"]]
result <- ComBat(dat = dat, batch = batch, mod = mod) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
str(result)
stopifnot(all.equal(result, result_truth))

plan(sequential)
} ## if (requireNamespace("sva") && ...)
