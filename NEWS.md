# Version (development version)

## New Transpilers

 * Add support for map-reduce CRAN package **stars**, e.g. `sm <-
   st_apply(s, MARGIN = 1, FUN = mean) |> futurize()`.


# Version 0.3.0 (2026-04-01)

## New Features

 * Add support for descending calls wrapped in `with()`.
 
 * Add default future labels that reflect what function call has been
   futurized.
 
 * Errors produced when an unsupported call is attempted now includes
   the version of the **futurize** package.

## Bug Fixes

 * `futurize(label = name)` was ignored for **crossmap** and **purrr**
   calls.


# Version 0.2.0 (2026-03-18)

Following the initial CRAN release in January 2026, this version adds
`futurize()` support for many more CRAN and Bioconductor packages. To
achieve this, support for transpiling S3 and S4 methods was added,
expanding beyond regular and generic functions. This opens the door
for futurizing many more packages going forward.

## Significant Changes

 * Add support for futurizing S3 methods where the S3 generic is
   defined in another package.

 * Add support for futurizing S4 methods where the S4 generic is
   defined in another package.

## New Features

 * Add support for disabling `futurize()` transpilation via R option
   `futurize.enable`, which may be set via environment variable
   `R_FUTURIZE_ENABLE` when the package is loaded.

## New Transpilers

 * Add support for map-reduce CRAN package **pbapply**, e.g. `y <-
   pblapply(...)  |> futurize()`.

 * Add support for domain-specific Bioconductor package **DESeq2**,
   e.g. `dds <- DESeq(dds) |> futurize()`.

 * Add support for domain-specific Bioconductor package **fgsea**,
   e.g. `res <- fgsea(pathways, stats) |> futurize()`.

 * Add support for domain-specific Bioconductor package
   **GenomicAlignments**, e.g. `se <- summarizeOverlaps(features,
   bam_files) |> futurize()`.

 * Add support for domain-specific CRAN package **fwb**, e.g. `b <-
   fwb(data, statistic, R = 1000) |> futurize()`.

 * Add support for domain-specific CRAN package **gamlss**,
   e.g. `cv <- gamlssCV(y ~ pb(x), data = abdom, K.fold = 10) |>
   futurize()`.

 * Add support for domain-specific CRAN package **glmmTMB**, e.g. `pr
   <- profile(m) |> futurize()`.

 * Add support for domain-specific CRAN package **kernelshap**,
   e.g. `ks <- kernelshap(model, X = x_explain, bg_X = bg_X) |>
   futurize()`.

 * Add support for domain-specific Bioconductor package **GSVA**,
   e.g. `es <- gsva(gsvaParam(expr, geneSets)) |> futurize()`.

 * Add support for domain-specific CRAN package **metafor**, e.g. `pr
   <- profile(fit) |> futurize()`.

 * Add support for domain-specific CRAN package **partykit**, e.g. `cf
   <- cforest(dist ~ speed, data = cars) |> futurize()`.


 * Add support for domain-specific CRAN package **riskRegression**,
   e.g. `sc <- Score(list("CSC" = fit), data = d, formula =
   Hist(time, event) ~ 1, times = 5, B = 100, split.method =
   "bootcv") |> futurize()`.

 * Add support for domain-specific Bioconductor package **scater**,
   e.g. `sce <- runPCA(sce) |> futurize()`.

 * Add support for domain-specific Bioconductor package **scuttle**,
   e.g. `sce <- logNormCounts(sce) |> futurize()`.

 * Add support for Bioconductor package **Rsamtools**,
   e.g. `counts <- countBam(bamViews) |> futurize()`.

 * Add support for Bioconductor package **SingleCellExperiment**,
   e.g. `result <- applySCE(sce, perCellQCMetrics) |> futurize()`.

 * Add support for Bioconductor package **sva**,
   e.g. `adjusted <- ComBat(dat, batch) |> futurize()`.

 * Add support for domain-specific CRAN package **seriation**, e.g. `o
   <- seriate_best(d_supreme) |> futurize()`.

 * Add support for domain-specific CRAN package **SimDesign**,
   e.g. `res <- runSimulation(design, replications = 1000, generate,
   analyse, summarise) |> futurize()`.

 * Add support for domain-specific CRAN package **shapr**,
   e.g. `result <- explain(model, x_explain, x_train, approach, phi0)
   |> futurize()`.

 * Add support for domain-specific CRAN package **strucchange**,
   e.g. `bp <- breakpoints(Nile ~ 1) |> futurize()`.

 * Add support for domain-specific CRAN package **TSP**, e.g. `tour <-
   solve_TSP(USCA50, method = "nn", rep = 10) |> futurize()`.

 * Add support for domain-specific CRAN package **vegan**, e.g. `md <-
   mrpp(dune, Management) |> futurize()`.

## Bug Fixes

 * `futurize()` option `chunk_size` was silently ignored for
   transpilers relying on **doFuture**.

 * `futurize()` failed to descend wrapped calls such as `local()` and
   `suppressWarnings()` that specified additional arguments. For
   example, `local({ lapply( ... ) }, envir = env) |> futurize()`
   would produce a parsing error.

 * Packages not supporting specifying a random seed will now produce
   an informative error message if `futurize(seed = <numeric>)` is
   specified, e.g. **boot**, **glmmTMB**, **lme4**, **mgcv**, and
   **vegan**.
   
 
# Version 0.1.0 (2026-01-18)

This is the first version submitted to CRAN.


# Version 0.0.6 (2026-01-14)

## New Transpilers

 * Add support for domain-specific CRAN package **mgcv**, e.g. `b <-
   bam(...) |> futurize()`.

## New Features

 * Add `supported_packages()` and `supported_package_functions()`.
 
 * Rename argument `chunk.size` to `chunk_size`.

 * Add custom `print()` method for transpiled calls such that
   attributes are displayed for arguments and their content.
 
 * Transpiler can now handle nested, complex wrapped expressions.
 
 * Error messages now suggest using `%do%` when trying to futurize
   `foreach()` with `%dopar%` or `%dofuture%`.

 * Error messages now distinguish between infix operators
   (e.g. `%do%`) and functions (e.g. `lapply()`).


# Version 0.0.5 (2025-11-26)

## New Features

 * Add support for futurizing calls nested in one or more layers of
   `{ ... }`, `( ... )`, `local( ... )`, `I()`, and `identity()`, e.g.
   `local({ lapply(x, f) }) |> futurize()` is the same as
   `local({ lapply(x, f) |> futurize() })`.


# Version 0.0.4 (2025-09-26)

## New Transpilers

 * Add support for domain-specific CRAN package **tm**, e.g. `m <-
   tm_map(crude, content_transformer(tolower)) |> futurize()`.

## New Features

 * Handle nested transpilers.

 * Add `futurize(when = {condition})` for futurizing conditioned on an
   R expression at runtime, e.g. `lapply(xs, fun) |> futurize(when =
   (length(xs) > 10))`.

 * Add `futurize(FALSE)` and `futurize(TRUE)` for disabling and
   enabling futurizing of calls.

 
# Version 0.0.3 (2025-08-20)

## New Transpilers

 * Add support for domain-specific CRAN package **caret**, e.g. `model
   <- train(Species ~ ., data = iris, method = "rf", trControl = ctrl)
   |> futurize()`.
   
 * Add support for `times()` and `%:%` of **foreach**, which require
   special care when it comes to passing future options,
   e.g. `futurize(seed = FALSE)`.

## New Features

 * The default future options for `futurize()` are now customized such
   that they work in more cases, e.g. there is no need to declare `seed =
   TRUE` for `replicate(3, rnorm(1)) |> futurize()`.

 * `futurize()` gained argument `eval`, which can be used to return
   the futurized expression instead of evaluating it.
 

# Version 0.0.2 (2025-05-23)

The **futurize** package unifies our current **future.apply**,
**furrr**, and **doFuture** solutions into a minimal, unified
API. This means you no longer need to learn those future-specific
packages and their APIs, and all you need to know is the `... |>
futurize()` syntax.  The default behavior of `futurize()` is
sufficient for most use cases and users, but, if needed, it comes with
one unifying, unique set of arguments that can be used to configure
how the futures are resolved, how they are partitioned into chunks,
and how output and conditions are relayed, among other things.

## New Transpilers

 * Add support for base R, e.g. `y <- lapply(xs, fcn) |> futurize()`,
   `y <- by(xs, idxs, fcn) |> futurize()`, and `xs <- kernapply(x, k)
   |> futurize()`.

 * Add support for map-reduce CRAN package **purrr**, e.g. `y <-
   map(xs, fcn) |> futurize()`.
 
 * Add support for map-reduce CRAN package **crossmap**, e.g. `y <-
   xmap_dbl(xs, fcn) |> futurize()`.
 
 * Add support for map-reduce CRAN package **foreach**, e.g. `y <-
   foreach(x = xs) %do% { fcn(x) } |> futurize()`.
 
 * Add support for map-reduce CRAN package **plyr**, e.g. `y <-
   llply(xs, fcn) |> futurize()`.
 
 * Add support for map-reduce Bioconductor package **BiocParallel**,
   e.g. `y <- bplapply(xs, fcn) |> futurize()`.

 * Add support for domain-specific CRAN package **boot**, e.g. `b <-
   boot(data, statistic, R = 1000) |> futurize()`.

 * Add support for domain-specific CRAN package **glmnet**, e.g. `cv
   <- cv.glmnet(x, y) |> futurize()`.

 * Add support for domain-specific CRAN package **lme4**, e.g. `gm <-
   allFit(gm) |> futurize()`.

 
# Version 0.0.1 (2025-03-07)

## New Features

 * Implemented a working proof-of-concept of a `futurize()` function
   that takes a call expression to any base-R apply function and
   transpiles it such that it runs in parallel via futures. This works
   by transpiling the original map-reduce call to evaluate each
   iteration via a lazy, vanilla future. These futures are then
   partitioned into chunks, where the number of chunks defaults to the
   number of parallel workers. The futures in each chunk are merged
   into a single future. These futures are then launched in parallel
   on the current future backend. When resolved, the results are
   reduced back to the structure that the original base R apply
   function would return.
