library(futurize)

message("*** futurize() with add-on package not installed")

## Register a factory function for the 'tools' package that requires a
## non-existing package, which mimics, e.g., futurizing base::lapply()
## when 'future.apply' is not installed (or not declared as a dependency
## when running 'R CMD check')
futurize:::transpilers_for_package("futurize::add-on", package = "tools", function() {
  loadNamespace("futurize.nonexisting.pkg")
  c("futurize.nonexisting.pkg")
})

res <- tryCatch({
  tools::file_ext("foo.txt") |> futurize()
}, error = identity)
print(res)
stopifnot(
  inherits(res, "error"),
  grepl("Please install", conditionMessage(res)),
  grepl("futurize.nonexisting.pkg", conditionMessage(res)),
  grepl("tools::file_ext()", conditionMessage(res), fixed = TRUE)
)

message("*** futurize() with add-on package not installed ... done")
