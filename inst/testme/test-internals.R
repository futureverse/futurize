library(futurize)
options(futurize.debug = TRUE)

message("*** Internals")

# --------------------------------------------------------------------
# Debug functions
# --------------------------------------------------------------------
message("debug_indent()")
oopts <- options(warn = 2L)
res <- tryCatch(futurize:::debug_indent(delta = -1L), error = identity)
print(res)
stopifnot(inherits(res, "error"))
options(oopts)


# --------------------------------------------------------------------
# .onLoad()
# --------------------------------------------------------------------
message(".onLoad()")
futurize:::.onLoad("futurize", "futurize")


# --------------------------------------------------------------------
# bquote_compile() and bquote_apply()
# --------------------------------------------------------------------
message("bquote_compile() and bquote_apply()")
bquote_compile <- futurize:::bquote_compile
bquote_apply <- futurize:::bquote_apply

message("- substitute NULL into second pairlist element")
## Substituting Y = NULL in function(a = .(X), b = .(Y)) { a + b } should
## set the second argument value to NULL. There used to be a bug that hard
## coded it to always update the first argument.
tmpl <- bquote_compile(function(a = .(X), b = .(Y)) { a + b })
expr <- bquote_apply(tmpl, X = 42, Y = NULL)
f <- formals(eval(expr))
stopifnot(identical(f$a, 42))
stopifnot(is.null(f$b))


# --------------------------------------------------------------------
# import_future() and import_from()
# --------------------------------------------------------------------
message("import_future() and import_from()")
import_from <- futurize:::import_from
import_future <- futurize:::import_future

fcn <- import_future("plan")
stopifnot(is.function(fcn))

fcn <- import_future("nonExistingFcn", default = identity)
stopifnot(identical(fcn, identity))

res <- tryCatch(
  import_future("nonExistingFcn"),
  error = identity
)
stopifnot(inherits(res, "error"))

fcn <- import_from("lapply", package = "base")
stopifnot(identical(fcn, base::lapply))

fcn <- import_from("nonExisting", package = "base", default = sum)
stopifnot(identical(fcn, sum))

res <- tryCatch(
  import_from("nonExisting", package = "base"),
  error = identity
)
stopifnot(inherits(res, "error"))
