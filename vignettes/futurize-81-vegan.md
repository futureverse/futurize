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
<img src="../man/figures/cran-vegan-logo.svg" alt="The 'vegan' logo">
<span>+</span>
<img src="../man/figures/futurize-logo.png" alt="The 'futurize' hexlogo">
<span>=</span>
<img src="../man/figures/future-logo.png" alt="The 'future' logo">
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
dune.mrpp <- with(dune.env, {
  mrpp(dune, Management) |> futurize()
})
```

# Introduction

The **[vegan]** package provides methods for community and vegetation ecologists. Some of the functions has built-in support for parallelization, which the **futurize** simplifies further.

## Example: 

Example adopted from `help("mrpp", package = "vegan")`:

```r
library(futurize)
plan(multisession)
library(vegan)

data(dune)
data(dune.env)
dune.mrpp <- with(dune.env, {
  mrpp(dune, Management) |> futurize()
})
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


# Supported Functions

The following **vegan** functions are supported by `futurize()`:

* `adonis()`
* `adonis2()`
* `anosim()`
* `estaccumR()`
* `mantel()`
* `mantel.partial()`
* `metaMDSiter()`
* `mrpp()`
* `oecosimu()`
* `ordiareatest()`
* `permutest()` for 'betadisper', and 'cca'
* `simper()`

[vegan]: https://cran.r-project.org/package=vegan
[other parallel backends]: https://www.futureverse.org/backends.html
