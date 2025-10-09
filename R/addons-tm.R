# tm::tm_index(...) =>
#
# local({
#   old_engine <- tm::tm_parLapply_engine()
#   on.exit(tm::tm_parLapply_engine(old_engine))
#   tm::tm_parLapply_engine(
#     future::makeClusterFuture(<future arguments>)
#   )
#   tm::tm_index(...)
# })
#
append_transpilers_for_tm <- function() {
  package <- "tm"

  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of '%s' functions requires R (>= 4.4.0)", getRversion(), package))
  }

  template <- quote(
    local({
      old_engine <- tm::tm_parLapply_engine()
      oopts <- options(future.ClusterFuture.clusterEvalQ = "error")
      on.exit({
        options(oopts)
        tm::tm_parLapply_engine(old_engine)
      })
      tm::tm_parLapply_engine(
        do.call(makeClusterFuture, args = OPTS)
      )
      EXPR
    })
  )
  idx_OPTS <- c(2, 5, 2, 3)
  idx_EXPR <- c(2, 6)
  
  ## To please 'R CMD check' on R (< 4.4.0), where
  ## future::makeClusterFuture() is not available
  call <- as.call(lapply(c("::", "future", "makeClusterFuture"), as.name))
  template[[c(2,4,2,2)]] <- call

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
      template[[idx_OPTS]] <- make_options(options, defaults = list(packages = "tm"))
      template[[idx_EXPR]] <- expr
      template
    }))
    body(transpiler) <- body(transpiler)
    transpiler
  }

  transpilers <- list()

  ns <- getNamespace(package)
#  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
#  names <- exports
  
  names <- c("tm_map", "tm_index", "TermDocumentMatrix")
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

  append_transpilers("futurize", "add-on", transpilers)

  ## Return required packages
  c(package, "future")
}
