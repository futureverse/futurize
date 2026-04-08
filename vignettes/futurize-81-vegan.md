<!--
%\VignetteIndexEntry{Parallelize 'vegan' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vegan}
%\VignetteKeyword{vignette}
%\VignetteKeyword{futurize}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-vegan-logo.webp" alt="The 'vegan' logo">
<span>+</span>
<img src="../man/figures/futurize-logo.webp" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.webp" alt="The 'future' logo">
</div>

The **futurize** package allows you to easily turn sequential code
into parallel code by piping the sequential code to the `futurize()`
function. Easy!


# TL;DR

```r
library(futurize)
plan(multisession)
library(vegan)

data(dune)
data(dune.env)
dune.mrpp <- with(dune.env, { mrpp(dune, Management) }) |> futurize()
```

# Introduction

The **[vegan]** package provides methods for community and
vegetation ecologists. Some of the functions have built-in support
for parallelization, which **futurize** simplifies further.

## Example: MRPP

Example adopted from `help("mrpp", package = "vegan")`:

```r
library(futurize)
plan(multisession)
library(vegan)

data(dune)
data(dune.env)
dune.mrpp <- with(dune.env, { mrpp(dune, Management) }) |> futurize()
```

This will parallelize the computations, given that we have set up
parallel workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and works on all operating systems. There are [other
parallel backends] to choose from, including alternatives to
parallelize locally as well as distributed across remote machines,
e.g.

```r
plan(future.mirai::mirai_multisession)
```

and

```r
plan(future.batchtools::batchtools_slurm)
```


## Example: anova() for 'cca' objects

The `anova()` S3 method for 'cca' objects supports parallelization via
the `parallel` argument. With **futurize**, you can parallelize this
directly. Example adopted from `help("anova.cca", package = "vegan")`:

```r
library(futurize)
plan(multisession)
library(vegan)

data(dune)
data(dune.env)
ord <- cca(dune ~ A1 + Management, data = dune.env)
res <- anova(ord, permutations = 99) |> futurize()
```


# Supported Functions

The following **vegan** functions are supported by `futurize()`:

* `adonis()`
* `adonis2()`
* `anova()` for 'cca'
* `anosim()`
* `cascadeKM()`
* `estaccumR()`
* `mantel()`
* `mantel.partial()`
* `metaMDSiter()`
* `mrpp()`
* `oecosimu()`
* `ordiareatest()`
* `permutest()` for 'betadisper', and 'cca'

# Without futurize: Manual PSOCK cluster setup

For comparison, here is what it takes to parallelize `mrpp()` using
the **parallel** package directly, without **futurize**:

```r
library(vegan)
library(parallel)

data(dune)
data(dune.env)

## Set up a PSOCK cluster
ncpus <- 4L
cl <- makeCluster(ncpus)

## Run MRPP in parallel
dune.mrpp <- with(dune.env, {
  mrpp(dune, Management, parallel = cl)
})

## Tear down the cluster
stopCluster(cl)
```

This requires you to manually create and manage the cluster
lifecycle. If you forget to call `stopCluster()`, or if your code
errors out before reaching it, you leak background R processes. You
also have to decide upfront how many CPUs to use and what cluster
type to use. Switching to another parallel backend, e.g. a Slurm
cluster, would require a completely different setup. With
**futurize**, all of this is handled for you - just pipe to
`futurize()` and control the backend with `plan()`.


[vegan]: https://cran.r-project.org/package=vegan
[other parallel backends]: https://www.futureverse.org/backends.html
