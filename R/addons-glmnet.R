# glmnet::cv.glmnet(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
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

  make_transpiler <- function(name) {
    defaults <- list()
    if (name == "cv.glmnet") {
      defaults <- list(seed = TRUE)
    }
    
    transpiler <- eval(bquote(function(expr, options = NULL) {
      ## Handle 'covr'
      is_covr <- (length(template[[c(3, 2)]]) > 2L)
      if (is_covr) {
        idx_OPTS <- c(3, 2, 3, 3, 2)
        idx_EXPR <- c(3, 3, 3, 3)
      } else {
        idx_OPTS <- c(3, 2, 2)
        idx_EXPR <- c(3, 3)
      }
      
      ## Update 'OPTS'
      template[[idx_OPTS]] <- make_options_for_doFuture(options, defaults = .(defaults), wrap = FALSE)
      
      ## Update 'EXPR'
      parts <- c(
        as.list(expr),
        parallel = TRUE
      )
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

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "doFuture")
}
