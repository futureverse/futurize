decend_wrappers <- function(expr, envir = parent.frame(), unwrap, what = "unwrap", debug = FALSE) {
  ## Nothing to do?
  if (length(unwrap) == 0) return(1L)
  
  if (debug) {
    mdebug_push("decend_wrappers() ...")
    on.exit(mdebug_pop())
  }

  call <- expr[[1]]  ## e.g. {, local, lapply, ...
  if (debug) {
    mdebug("Call:")
    mprint(call)
  }
  
  call_info <- parse_call(call, envir = envir, what = what, debug = debug)
  fcn <- call_info[["fcn"]]
  fcn_name <- call_info[["fcn_name"]]
  ns_name <- call_info[["ns_name"]]

  for (wrapper in unwrap) {
    if (identical(fcn, wrapper)) {  ## a wrapper call?
      if (debug) {
        info <- switch(fcn_name,
          "{" = "{ ... }",
          "(" = "( ... )",
          sprintf("%s( ... )", fcn_name)
        )
        mdebugf("Wrapped in %s", info)
      }
      index <- length(expr)
      return(c(length(expr), decend_wrappers(expr[[index]], envir = envir, unwrap = unwrap, what = what, debug = debug)))
    } ## if (identical(fcn, wrapper)
  } ## for (wrapper in unwrap)
  
  return(1L)
} ## decend_wrappers()



#' @export
print.transpiled_call <- function(x, ...) {
  stopifnot(inherits(x, "call"))

  ...x_org... <- x

  ## Make sure attributes are displayed
  ## Wooa; this might be more convoluted than writing a custom
  ## print() method from scratch
  ...x... <- as.list(x)
  for (...kk... in seq_along(...x...)) {
    ...x...[[...kk...]] <- local({
      expr <- ...x...[[...kk...]]
      code <- c("substitute(", deparse(expr), ")")
      tryCatch({
        eval(parse(text = code, enclos = emptyenv()))
      }, error = function(e) {
        ## Some deparsed expression cannot be parsed
        expr
      })
    })
  }
  x <- as.call(...x...)
  
  NextMethod()

  invisible(...x_org...)
}
