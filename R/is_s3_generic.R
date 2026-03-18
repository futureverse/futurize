#' Check whether function is an S3 generic function
#'
#' @param fcn A function.
#'
#' @return
#' Return TRUE if `fcn` is an S3 generic function, otherwise FALSE.
#'
#' @noRd
is_s3_generic <- local({
  has_UseMethod <- function(expr) {
    if (is.call(expr)) {
      first <- expr[[1]]
      if (is.symbol(first) && identical(first, as.symbol("UseMethod"))) {
        return(TRUE)
      }
      for (ii in seq_along(expr)) {
        if (has_UseMethod(expr[[ii]])) return(TRUE)
      }
    }
    FALSE
  } ## has_UseMethod()

  function(fcn) {
    if (is.primitive(fcn)) return(FALSE)
    bd <- body(fcn)
    if (is.null(bd)) return(FALSE)
    has_UseMethod(bd)
  }
}) ## is_s3_generic()
