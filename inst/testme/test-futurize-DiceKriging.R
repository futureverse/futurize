#' @tags pkg-DiceKriging
if (requireNamespace("DiceKriging") && requireNamespace("doFuture")) {
library(futurize)
library(DiceKriging)
options(future.rng.onMisuse = "ignore")

plan(multisession)

## -------------------------------------------------------------------
## km() - kriging model with multistart optimization
## -------------------------------------------------------------------
## Adopted from help("km", package = "DiceKriging")
set.seed(42)
n <- 20L
d <- 2L
design.fact <- expand.grid(seq(0, 1, length = 4), seq(0, 1, length = 4))
design.fact <- data.frame(design.fact)
names(design.fact) <- c("x1", "x2")
y <- apply(design.fact, 1, function(x) x[1]^2 + x[2]^2)
response <- data.frame(y = y)

## Sequential (truth)
set.seed(42)
m_truth <- km(~., design = design.fact, response = response,
              multistart = 4L)
cat(sprintf("km truth: range = [%s]\n",
            paste(round(coef(m_truth, "range"), 4), collapse = ", ")))

## Futurized
set.seed(42)
m_fz <- km(~., design = design.fact, response = response,
           multistart = 4L) |> futurize_and_verify()
cat(sprintf("km futurized: range = [%s]\n",
            paste(round(coef(m_fz, "range"), 4), collapse = ", ")))

stopifnot(all.equal(coef(m_truth, "range"), coef(m_fz, "range"), tolerance = 1e-3))

plan(sequential)
} ## if (requireNamespace("DiceKriging"))
