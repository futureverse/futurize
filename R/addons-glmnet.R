# glmnet::cv.glmnet(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = ...)
#   glmnet::cv.glmnet(..., parallel = TRUE)
# })
#
append_transpilers_for_glmnet <- function() {
  template <- quote(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = OPTS)
      EXPR
    })
  )

  make_options <- function(options) {
    options
  }

  transpiler <- eval(bquote(function(expr, options = NULL) {
    
    ## Update 'OPTS'
    idx_OPTS <- c(3, 2, 2)
    template[[idx_OPTS]] <- make_options(options)
    
    ## Update 'EXPR'
    parts <- c(
      as.list(expr),
      parallel = TRUE
    )
    idx_EXPR <- c(3, 3)
    template[[idx_EXPR]] <- as.call(parts)
    
    template
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace("glmnet")
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if ("parallel" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("glmnet::%s() ~> glmnet::%s(..., parallel = TRUE)", name, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "glmnet"

  append_transpilers("add-on", transpilers)

  ## Return required packages
  c("glmnet", "doFuture")
}
