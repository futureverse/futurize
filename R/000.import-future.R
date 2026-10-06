## The 'futurize' package don't really need to have a hard dependency on
## the 'future' package. However, we make 'futurize' attach 'future' for
## conveniency so that `plan()` is available.
#' @importFrom future plan
import_future <- function(name, default = NULL) {
  import_from(name, default = default, package = "future")
}
