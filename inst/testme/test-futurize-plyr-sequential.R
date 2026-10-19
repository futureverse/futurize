if (requireNamespace("plyr", quietly = TRUE) && requireNamespace("doFuture", quietly = TRUE)) {
library(futurize)

plan(sequential)

message("*** plyr::llply() |> futurize() with plan(sequential) - no plyr warning")
warnings <- list()
y <- withCallingHandlers({
  plyr::llply(1:2, identity) |> futurize()
}, warning = function(w) {
  warnings <<- c(warnings, list(w))
  invokeRestart("muffleWarning")
})
str(warnings)
stopifnot(
  identical(y, list(1L, 2L)),
  length(warnings) == 0L
)

message("*** Warnings from the user's function are still relayed")
res <- tryCatch({
  plyr::llply(1:2, function(x) { warning("boom"); x }) |> futurize()
}, warning = identity)
print(res)
stopifnot(
  inherits(res, "warning"),
  conditionMessage(res) == "boom"
)

message("*** Visibility is preserved")
res <- withVisible(plyr::llply(1:2, identity) |> futurize())
stopifnot(res$visible)
}
