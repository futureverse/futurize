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

  template <- bquote_compile(
    local({
      old_engine <- tm::tm_parLapply_engine()
      oopts <- options(future.ClusterFuture.clusterEvalQ = "error")
      on.exit({
        options(oopts)
        tm::tm_parLapply_engine(old_engine)
      })
      tm::tm_parLapply_engine(
        do.call(.(CALL), args = .(OPTS))
      )
      .(EXPR)
    })
  )
  
  ## To please 'R CMD check' on R (< 4.4.0), where
  ## future::makeClusterFuture() is not available
  call <- as.call(lapply(c("::", "future", "makeClusterFuture"), as.name))

  make_transpiler <- function(name) {
    transpiler <- function(expr, options = NULL) {
      bquote_apply(template,
        CALL = call,
        OPTS = make_options_for_makeClusterFuture(options, defaults = list(packages = "tm")),
        EXPR = expr
      )
    }
    body(transpiler) <- body(transpiler)
    transpiler
  }

  transpilers <- make_package_transpilers(package, FUN = function(fcn, package, name) {
    if (!name %in% c("tm_map", "tm_index", "TermDocumentMatrix")) return(NULL)
    list(
      label = sprintf("%s::%s() ~> %s::%s(..., parallel = TRUE)", package, name, package, name),
      transpiler = make_transpiler(name)
    )
  })

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "future")
}
