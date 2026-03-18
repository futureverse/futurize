library(futurize)
options(futurize.debug = TRUE)

message("*** Internals")

message("debug_indent()")
try(futurize:::debug_indent(delta = -1L))

message(".onLoad()")
futurize:::.onLoad("futurize", "futurize")

message("*** import_future() and import_from()")
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
