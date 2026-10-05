## Assert that future options are never pass via '.options.future'
library(futurize)

message("*** foreach(..., .options.future = <user options>) %do% { ... }")
if (requireNamespace("foreach", quietly = TRUE) && requireNamespace("doFuture", quietly = TRUE)) {
  library(foreach)
  plan(sequential)

  user_opts <- list(seed = TRUE)
  exprs <- list(
    literal  = quote(foreach(x = 1:2, .options.future = list(seed = TRUE)) %do% { x }),
    variable = quote(foreach(x = 1:2, .options.future = user_opts) %do% { x }),
    nested_inner = quote(foreach(x = 1:2) %:% foreach(y = 1:2, .options.future = list(seed = TRUE)) %do% { x * y }),
    nested_outer = quote(foreach(x = 1:2, .options.future = list(seed = TRUE)) %:% foreach(y = 1:2) %do% { x * y }),
    nested3_outer = quote(foreach(x = 1:2, .options.future = list(seed = TRUE)) %:% foreach(y = 1:2) %:% foreach(z = 1:2) %do% { x * y * z }),
    nested3_middle = quote(foreach(x = 1:2) %:% foreach(y = 1:2, .options.future = list(seed = TRUE)) %:% foreach(z = 1:2) %do% { x * y * z })
  )

  for (name in names(exprs)) {
    message("- ", name)
    res <- tryCatch({
      futurize(exprs[[name]], substitute = FALSE, eval = FALSE)
    }, error = identity)
    print(res)
    stopifnot(
      inherits(res, "error"),
      grepl("futurize(seed = TRUE)", conditionMessage(res), fixed = TRUE)
    )
  }

  ## Other foreach() arguments are still allowed
  y <- futurize(foreach(x = 1:2, .inorder = TRUE) %do% { x }, seed = TRUE)
  stopifnot(identical(y, list(1L, 2L)))
}

