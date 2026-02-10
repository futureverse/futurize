if (requireNamespace("fwb") && requireNamespace("boot")) {
  library(futurize)
  library(fwb)
  city <- boot::city
  options(future.rng.onMisuse = "error")

  all_equal <- function(a, b, ...) {
    a$call <- b$call <- NULL
    all.equal(a, b, ...)
  }

  plan(multisession)

  ## Adopted from example("boot", package = "boot")
  ratio <- function(d, w) {
    sum(d$x * w)/sum(d$u * w)
  }

  set.seed(42)
  b_truth <- fwb(city, ratio, R = 999, verbose = FALSE, simple = FALSE)
  print(b_truth)

  set.seed(42)
  b <- fwb(city, ratio, R = 999, verbose = FALSE, simple = FALSE) |> futurize()
  print(b)

  stopifnot(all_equal(b, b_truth, check.attributes = FALSE))

  #vcovFWB
  fit <- lm(u ~ x, data = city)

  set.seed(42)
  v_truth <- vcovFWB(fit, R = 999)
  print(v_truth)

  set.seed(42)
  v <- vcovFWB(fit, R = 999) |> futurize()
  print(v)

  #v and v_truth should differ if parallelization is done
  stopifnot(!isTRUE(all.equal(v_truth, v)))

  set.seed(42)
  v2 <- vcovFWB(fit, R = 999, cl = "future")
  print(v2)

  #v and v2 should not differ if futurize() engages cl = "future"
  stopifnot(all.equal(v, v2))

  plan(sequential)
} ## if (requireNamespace("fwb") && requireNamespace("boot"))
