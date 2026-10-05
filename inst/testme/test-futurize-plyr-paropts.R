## Assert that plyr argument '.paropts' does not specify '.options.future'
## and that futurize() options are appended.
library(futurize)

message("*** plyr::llply(..., .paropts = <user options>)")
if (requireNamespace("plyr", quietly = TRUE) && requireNamespace("doFuture", quietly = TRUE)) {
  plan(sequential)

  ## User's .paropts are kept, and futurize options are added
  expr <- quote(plyr::llply(1:2, identity, .paropts = list(.inorder = TRUE)))
  expr2 <- futurize(expr, substitute = FALSE, packages = "stats", eval = FALSE)
  print(expr2)
  call <- expr2[[3]][[2]]
  stopifnot(sum(names(call) == ".paropts") == 1L)
  paropts <- eval(call[[".paropts"]])
  str(paropts)
  stopifnot(
    isTRUE(paropts[[".inorder"]]),
    identical(paropts[[".options.future"]][["packages"]], "stats")
  )

  y <- futurize(expr, substitute = FALSE, packages = "stats")
  stopifnot(identical(y, list(1L, 2L)))

  ## User's .paropts must not specify .options.future
  user_paropts <- list(.options.future = list(seed = TRUE))
  exprs <- list(
    literal  = quote(plyr::llply(1:2, identity, .paropts = list(.options.future = list(seed = TRUE)))),
    variable = quote(plyr::llply(1:2, identity, .paropts = user_paropts))
  )
  for (name in names(exprs)) {
    message("- ", name)
    res <- tryCatch({
      futurize(exprs[[name]], substitute = FALSE)
    }, error = identity)
    print(res)
    stopifnot(
      inherits(res, "error"),
      grepl("futurize(seed = TRUE)", conditionMessage(res), fixed = TRUE)
    )
  }
}
