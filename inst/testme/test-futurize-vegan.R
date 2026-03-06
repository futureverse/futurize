if (requireNamespace("vegan") && getRversion() >= "4.4.0") {

all_equal_ignore_call <- function(a, b, ...) {
  attr(a, "heading") <- attr(b, "heading") <- NULL
  a$call <- b$call <- NULL
  a <- lapply(a, FUN = function(x) if ("call" %in% names(x)) x$call <- NULL)
  b <- lapply(b, FUN = function(x) if ("call" %in% names(x)) x$call <- NULL)
  if (is.list(a)) {
    a$control <- b$control <- NULL
  }
  if (!is.null(a$perm)) {
    a$perm <- as.vector(a$perm)
    b$perm <- as.vector(a$perm)
    names(a$perm) <- names(b$perm) <- NULL
  }
  res <- all.equal(a, b, ...)
  if (!isTRUE(res)) {
    str(list(a = a, b = b))
    print(res)
    str(res)
  }
  res
}


library(futurize)
library(vegan)
options(future.rng.onMisuse = "error")

plan(multisession)

data(dune)
data(dune.env)


message("*** mrpp()")

## Adopted from example("mrpp", package = "vegan")
set.seed(42)
res_truth <- mrpp(dune, dune.env$Management, permutations = 99)
print(res_truth)

set.seed(42)
res <- mrpp(dune, dune.env$Management, permutations = 99) |> futurize()
print(res)

stopifnot(all_equal_ignore_call(res, res_truth))


message("*** adonis2()")

## Adopted from example("adonis2", package = "vegan")
set.seed(42)
res_truth <- adonis2(dune ~ Management, data = dune.env, permutations = 99)
print(res_truth)

set.seed(42)
res <- adonis2(dune ~ Management, data = dune.env, permutations = 99) |> futurize()
print(res)

stopifnot(all_equal_ignore_call(res, res_truth))


message("*** anosim()")

## Adopted from example("anosim", package = "vegan")
set.seed(42)
res_truth <- anosim(dune, dune.env$Management, permutations = 99)
print(res_truth)

set.seed(42)
res <- anosim(dune, dune.env$Management, permutations = 99) |> futurize()
print(res)

stopifnot(all_equal_ignore_call(res, res_truth))


message("*** mantel()")

## Adopted from example("mantel", package = "vegan")
veg.dist <- vegdist(dune)
env.dist <- dist(dune.env[, "A1", drop = FALSE])

set.seed(42)
res_truth <- mantel(veg.dist, env.dist, permutations = 99)
print(res_truth)

set.seed(42)
res <- mantel(veg.dist, env.dist, permutations = 99) |> futurize()
print(res)

stopifnot(all_equal_ignore_call(res, res_truth))


message("*** mantel.partial()")

## Adopted from example("mantel.partial", package = "vegan")
xdis <- vegdist(dune)
ydis <- dist(dune.env$A1)
zdis <- xdis + ydis
set.seed(42)
res_truth <- mantel.partial(xdis, ydis, zdis, permutations = 99)
print(res_truth)

set.seed(42)
res <- mantel.partial(xdis, ydis, zdis, permutations = 99) |> futurize()
print(res)

stopifnot(all_equal_ignore_call(res, res_truth))


## https://github.com/vegandevs/vegan/issues/771
if ("cascadeKM" %in% futurize_supported_functions("vegan")) {
message("*** cascadeKM()")

## Adopted from example("cascadeKM", package = "vegan")
set.seed(42)
res_truth <- cascadeKM(dune, inf.gr = 2, sup.gr = 3, iter = 100)
#print(res_truth)

set.seed(42)
res <- cascadeKM(dune, inf.gr = 2, sup.gr = 3, iter = 100) |> futurize()
#print(res)

## NOTE: cascadeKM() is not numerically reproducible
res_truth$partition <- res$partition <- NULL
res_truth$size <- sort(res_truth$size)
res$size <- sort(res$size)
stopifnot(all_equal_ignore_call(res, res_truth))
} ## if ("cascadeKM" %in% futurize_supported_functions("vegan"))


message("*** estaccumR()")

## Adopted from example("estaccumR", package = "vegan")
set.seed(42)
res_truth <- estaccumR(dune, permutations = 9)
print(res_truth)

set.seed(42)
res <- estaccumR(dune, permutations = 9) |> futurize()
print(res)

stopifnot(all_equal_ignore_call(res, res_truth))


message("*** oecosimu()")
data(sipoo)

## Adopted from example("oecosimu", package = "vegan")
set.seed(42)
res_truth <- oecosimu(sipoo, nestedchecker, "r0")
print(res_truth)

set.seed(42)
res <- oecosimu(sipoo, nestedchecker, "r0") |> futurize()
print(res)

stopifnot(all_equal_ignore_call(res, res_truth))


if (FALSE) {
  ## Skip for now, because of
  ## https://github.com/HenrikBengtsson/future-ideas/issues/1052
  message("*** ordiareatest()")
   
  ## Adopted from example("ordiareatest", package = "vegan")
  ord <- rda(dune)
  
  set.seed(42)
  res_truth <- ordiareatest(ord, dune.env$Management, permutations = 9)
  print(res_truth)
   
  set.seed(42)
  res <- ordiareatest(ord, dune.env$Management, permutations = 9) |> futurize()
  print(res)
   
  stopifnot(all_equal_ignore_call(res, res_truth))
}


message("*** simper()")

## Adopted from example("simper", package = "vegan")
set.seed(42)
res_truth <- simper(dune, dune.env$Management, permutations = 9)
print(res_truth)

set.seed(42)
res <- simper(dune, dune.env$Management, permutations = 9) |> futurize()
print(res)

stopifnot(all_equal_ignore_call(res, res_truth))


plan(sequential)
} ## if (requireNamespace("vegan"))
