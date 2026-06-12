#' @tags skip_on_cran  ## to limit total check time
#' @tags pkg-Rsamtools
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

result <- countBam(bv) |> futurize_and_verify()
str(result)
stopifnot(all.equal(result, result_truth))


## ---------------------------------------------------------
## scanBam() with BamViews
## ---------------------------------------------------------
## scanBam() parallelizes via bplapply() when the input is
## a BamViews object, distributing work across BAM files.

result_truth <- scanBam(bv)
str(result_truth)

result <- scanBam(bv) |> futurize_and_verify()
str(result)
stopifnot(all.equal(result, result_truth))

## Cleanup
file.remove(bam_files)
file.remove(paste0(bam_files, ".bai"))

plan(sequential)
} ## if (requireNamespace("Rsamtools") && ...)
