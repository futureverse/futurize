if (requireNamespace("mice") && getRversion() >= "4.4.0") {
library(futurize)
library(mice)
options(future.rng.onMisuse = "error")

all_equal <- function(a, b, ...) {
  ## Cannot compare imputed values directly because RNG streams differ
  ## between sequential mice() and parallel futuremice(). Instead,
  ## compare structural properties of the mids objects.
  stopifnot(
    inherits(a, "mids"),
    inherits(b, "mids"),
    identical(a$m, b$m),
    identical(a$method, b$method),
    identical(a$predictorMatrix, b$predictorMatrix),
    identical(dim(a$data), dim(b$data))
  )
  invisible(TRUE)
}

plan(multisession)

## Adopted from example("mice", package = "mice")
message("Ordinary processing:")
set.seed(42)
imp_truth <- mice(nhanes, m = 5, printFlag = FALSE)
print(imp_truth)

message("Futurized processing:")
set.seed(42)
imp <- mice(nhanes, m = 5, printFlag = FALSE) |> futurize()
print(imp)

message("Comparing results:")
all_equal(imp, imp_truth)

plan(sequential)
} ## if (requireNamespace("mice"))
