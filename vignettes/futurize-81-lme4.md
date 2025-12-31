<!--
%\VignetteIndexEntry{Parallelize 'lme4' functions}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{lme4}
%\VignetteKeyword{vignette}
%\VignetteKeyword{handlers}
%\VignetteEngine{futurize::selfonly}
-->

<div class="logos">
<img src="../man/figures/cran-lme4-logo.svg" alt="The 'lme4' image">
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
library(lme4)
library(futurize)
plan(multisession)

gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
             data = cbpp, family = binomial)
gm_all <- allFit(gm) |> futurize()
```


# Introduction

This vignette demonstrates how use this approach to parallelize **[lme4]**
functions such as `lme4()` and `tslme4()`.


# Background

The **lme4** `llply()` function is commonly used to apply a function to
the elements of a list and return a list. For example, 

```r
library(lme4)

gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
             data = cbpp, family = binomial)
gm_all <- allFit(gm)
```

Here `lme4()` evaluates sequentially, but we can easily make it to
evaluate parallelly, by using:

```r
library(futurize)
library(lme4)


gm <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
             data = cbpp, family = binomial)
gm_all <- allFit(gm) |> futurize()
```

This will distribute the calculations across the available parallel
workers, given that we have set parallel workers, e.g.

```r
plan(multisession)
```

The built-in `multisession` backend parallelizes on your local
computer and it works on all operating system. There are [other
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

Another example is:

```r
library(lme4)
library(futurize)
plan(future.mirai::mirai_multisession)

lynx.fun <- function(tsb) {
     ar.fit <- ar(tsb, order.max = 25)
     c(ar.fit$order, mean(tsb), tsb)
}

lynx.1 <- tslme4(log(lynx), lynx.fun, R = 99, l = 20, sim = "geom") |> futurize()
```


# Supported Functions

The `futurize()` function supports parallelization of the common base
R functions. The following **lme4** functions are supported:

* `allFit()`
* `bootMer()`


[lme4]: https://cran.r-project.org/package=lme4
