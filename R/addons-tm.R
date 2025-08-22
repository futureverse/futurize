# tm::tm_index(...) =>
#
# local({
#   old_engine <- tm::tm_parLapply_engine()
#   on.exit(tm::tm_parLapply_engine(old_engine))
#   tm::tm_parLapply_engine(
#     future::makeClusterFuture(<future arguments>)
#   )
#   tm::index(...)
# })
#
append_transpilers_for_tm <- function() {
  package <- "tm"
  
  template <- quote(
    local({
      old_engine <- tm::tm_parLapply_engine()
      on.exit(tm::tm_parLapply_engine(old_engine))
      tm::tm_parLapply_engine(
        do.call(future::makeClusterFuture, args = OPTS)
      )
      EXPR
    })
  )
  idx_OPTS <- c(2, 4, 2, 3)
  idx_EXPR <- c(2, 5)

  make_options <- function(options, defaults = NULL) {
    if (length(defaults) > 0) {
      names <- setdiff(names(defaults), attr(options, "specified"))
      for (name in names) {
        if (name == "packages") {
          options[[name]] <- c(options[[name]], defaults[[name]])
        } else {
          options[[name]] <- defaults[[name]]
        }
      }
    }
    options
  }
  
  make_transpiler <- function(name) {
    transpiler <- eval(bquote(function(expr, options = NULL) {
      template[[idx_OPTS]] <- make_options(options, defaults = .(defaults))
      template[[idx_EXPR]] <- expr
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
      transpilers[[name]] <- list(
        label = sprintf("%s::%s() ~> %s::%s(..., parallel = TRUE)", package, name, package, name),
        transpiler = make_transpiler(name)
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("add-on", transpilers)

  ## Return required packages
  c(package, "future")
}
