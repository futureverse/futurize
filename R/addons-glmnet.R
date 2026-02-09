# glmnet::cv.glmnet(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   glmnet::cv.glmnet(..., parallel = TRUE)
# })
#
append_transpilers_for_glmnet <- function() {
  package <- "glmnet"

  template <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = .(OPTS))
      .(EXPR)
    })
  )

  make_transpiler <- function(name) {
    defaults <- list()
    if (name == "cv.glmnet") {
      defaults <- list(seed = TRUE)
    }

    transpiler <- function(expr, options = NULL) {
      ## Update 'EXPR'
      parts <- c(
        as.list(expr),
        parallel = TRUE
      )
      
      ## Update 'OPTS'
      bquote_apply(template,
        OPTS = make_options_for_doFuture(options, defaults = defaults, wrap = FALSE),
        EXPR = as.call(parts)
      )
    }
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

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "doFuture")
}
