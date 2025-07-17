# glmnet::cv.glmnet(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = ...)
#   glmnet::cv.glmnet(..., parallel = TRUE)
# })
#
append_transpilers_for_glmnet <- function() {
  package <- "glmnet"

  template <- quote(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = OPTS)
      EXPR
    })
  )

  make_options <- function(options, defaults = NULL) {
    if (length(defaults) > 0) {
      names <- setdiff(names(defaults), attr(options, "specified"))
      for (name in names) options[[name]] <- defaults[[name]]
    }
    options
  }
  
  make_transpiler <- function(name) {
    defaults <- list()
    if (name == "cv.glmnet") {
      defaults <- list(seed = TRUE)
    }
    
    transpiler <- eval(bquote(function(expr, options = NULL) {
      ## Update 'OPTS'
      idx_OPTS <- c(3, 2, 2)
      template[[idx_OPTS]] <- make_options(options, defaults = .(defaults))
      
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
    
    transpiler
  }

  transpilers <- list()

  ns <- getNamespace(package)
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if ("parallel" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("%s::%s() ~> %s::%s(..., parallel = TRUE)", package, name, package, name),
          transpiler = make_transpiler(name)
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("add-on", transpilers)

  ## Return required packages
  c(package, "doFuture")
}
