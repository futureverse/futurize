if (requireNamespace("Rsamtools") && requireNamespace("doFuture")) {
library(futurize)
library(Rsamtools)
options(future.rng.onMisuse = "error")

plan(multisession)


## ---------------------------------------------------------
## countBam() with BamViews
## ---------------------------------------------------------
## countBam() parallelizes via bplapply() when the input is
## a BamViews object, distributing work across BAM files.

## Create test BAM files (copies of example BAM)
fls <- system.file("extdata", "ex1.bam", package = "Rsamtools")
fls_idx <- paste0(fls, ".bai")
tmp_dir <- tempdir()
bam_files <- character(3L)
for (i in seq_along(bam_files)) {
  dst <- file.path(tmp_dir, sprintf("sample%d.bam", i))
  file.copy(fls, dst, overwrite = TRUE)
  if (file.exists(fls_idx))
    file.copy(fls_idx, paste0(dst, ".bai"), overwrite = TRUE)
  bam_files[i] <- dst
}

## Set up BamViews
bv <- BamViews(bam_files)

result_truth <- countBam(bv)
str(result_truth)

counters <- plan("backend")[["counters"]]
result <- countBam(bv) |> futurize()
str(result)
stopifnot(all.equal(result, result_truth))
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)

counters <- plan("backend")[["counters"]]
result2 <- Rsamtools::countBam(bv) |> futurize()
stopifnot(all.equal(result2, result_truth))
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)


## ---------------------------------------------------------
## scanBam() with BamViews
## ---------------------------------------------------------
## scanBam() parallelizes via bplapply() when the input is
## a BamViews object, distributing work across BAM files.

result_truth <- scanBam(bv)
str(result_truth)

counters <- plan("backend")[["counters"]]
result <- scanBam(bv) |> futurize()
str(result)
stopifnot(all.equal(result, result_truth))
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)

counters <- plan("backend")[["counters"]]
result2 <- Rsamtools::scanBam(bv) |> futurize()
stopifnot(all.equal(result2, result_truth))
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)

## Cleanup
file.remove(bam_files)
file.remove(paste0(bam_files, ".bai"))


plan(sequential)
} ## if (requireNamespace("Rsamtools") && ...)
