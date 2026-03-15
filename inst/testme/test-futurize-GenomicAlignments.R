if (requireNamespace("GenomicAlignments") && requireNamespace("Rsamtools") && requireNamespace("doFuture")) {
library(futurize)
library(GenomicAlignments)
library(Rsamtools)
options(future.rng.onMisuse = "error")

plan(multisession)


## ---------------------------------------------------------
## summarizeOverlaps() with BamFileList
## ---------------------------------------------------------
## summarizeOverlaps() parallelizes via bplapply() when the
## input is a BamFileList, distributing work across BAM files.

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

bf <- BamFileList(bam_files)
features <- GRanges("seq1",
  IRanges(start = c(1, 100, 200), end = c(50, 150, 250))
)
names(features) <- paste0("feature", 1:3)

result_truth <- summarizeOverlaps(features, bf)
str(result_truth)

counters <- plan("backend")[["counters"]]
result <- summarizeOverlaps(features, bf) |> futurize()
str(result)
stopifnot(all.equal(
  SummarizedExperiment::assay(result),
  SummarizedExperiment::assay(result_truth)
))
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)

counters <- plan("backend")[["counters"]]
result2 <- GenomicAlignments::summarizeOverlaps(features, bf) |> futurize()
stopifnot(all.equal(
  SummarizedExperiment::assay(result2),
  SummarizedExperiment::assay(result_truth)
))
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)

## Cleanup
file.remove(bam_files)
file.remove(paste0(bam_files, ".bai"))


plan(sequential)
} ## if (requireNamespace("GenomicAlignments") && ...)
