if (requireNamespace("Rsolnp") && getRversion() >= "4.4.0") {
library(futurize)
library(Rsolnp)

plan(multisession)

## -------------------------------------------------------------------
## gosolnp() - Global optimization using random starting parameters
## -------------------------------------------------------------------
## Adopted from help("gosolnp", package = "Rsolnp")
gofn <- function(pars, ...) {
  x <- pars[1]
  y <- pars[2]
  (x - 2)^2 + (y - 3)^2
}

counters <- plan("backend")[["counters"]]
res <- gosolnp(
  fun = gofn,
  LB = c(-10, -10),
  UB = c(10, 10),
  n.restarts = 2,
  n.sim = 100
) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (gosolnp): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(res$pars)
stopifnot(all(abs(res$pars - c(2, 3)) < 0.1))


## -------------------------------------------------------------------
## gosolnp() - with equality constraints
## -------------------------------------------------------------------
## Minimize x^2 + y^2 subject to x + y = 1
gofn2 <- function(pars, ...) {
  pars[1]^2 + pars[2]^2
}

goeqfn2 <- function(pars, ...) {
  pars[1] + pars[2]
}

counters <- plan("backend")[["counters"]]
res2 <- gosolnp(
  fun = gofn2,
  eqfun = goeqfn2,
  eqB = 1,
  LB = c(-10, -10),
  UB = c(10, 10),
  n.restarts = 2,
  n.sim = 100
) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (gosolnp with constraints): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
print(res2$pars)
stopifnot(all(abs(res2$pars - c(0.5, 0.5)) < 0.1))


## -------------------------------------------------------------------
## startpars() - Generate good starting parameters
## -------------------------------------------------------------------
## Adopted from help("startpars", package = "Rsolnp")
counters <- plan("backend")[["counters"]]
sp <- startpars(
  fun = gofn,
  LB = c(-10, -10),
  UB = c(10, 10),
  n.sim = 200,
  bestN = 5
) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created (startpars): %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(is.matrix(sp))
stopifnot(nrow(sp) == 5L)
## Last column is the objective function value
print(sp)

plan(sequential)
} ## if (requireNamespace("Rsolnp"))
