# caret::train(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   caret::train(..., parallel = TRUE)
# })
#
append_transpilers_for_caret <- function() {
  package <- "caret"

  template <- quote(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = OPTS)
      EXPR
    })
  )

  make_transpiler <- function(name, args = list(parallel = TRUE)) {
    defaults <- list(
      seed = TRUE
    )

    idx_OPTS <- c(3, 2, 2)
    idx_EXPR <- c(3, 3)

    transpiler <- eval(bquote(function(expr, options = NULL) {
      ## SPECIAL CASE: Are we running via 'covr'?
      if (length(template[[c(3, 2)]]) > 2L) {
        idx_OPTS <- c(3, 2, 3, 3, 2)
        idx_EXPR <- c(3, 3, 3, 3)
      }
      
      ## Update 'OPTS'
      template[[idx_OPTS]] <- make_options_for_doFuture(options, defaults = .(defaults), wrap = FALSE)
      
      ## Update 'EXPR'
      parts <- c(
        as.list(expr),
        .(args)
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
      ## nnnControl()
      if ("allowParallel" %in% names(formals(fcn))) {
        if (name == "nearZeroVar") {
          transpilers[[name]] <- list(
            label = sprintf("%s::%s() ~> %s::%s()", package, basename, package, basename),
            transpiler = make_transpiler(name, args = list(foreach = TRUE))
          )
        } else {
          ## nnnControl() -> nnn()
          basename <- sub("Control$", "", name)
          if (exists(basename, mode = "function", envir = ns, inherits = FALSE)) {
            transpilers[[basename]] <- list(
              label = sprintf("%s::%s() ~> %s::%s()", package, basename, package, basename),
              transpiler = make_transpiler(basename)
            )
          }
        }
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "doFuture")
}
