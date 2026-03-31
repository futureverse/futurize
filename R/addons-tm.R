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
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'tm' functions requires R (>= 4.4.0)", getRversion()))
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

  template2 <- bquote_compile(function(expr, options = NULL) {
    defaults <- list(
      packages = "tm",
      label = sprintf("fz:tm::%s", .(NAME))
    )
    opts <- make_options_for_makeClusterFuture(options, defaults = defaults)
    bquote_apply(template,
      CALL = call,
      OPTS = opts,
      EXPR = expr
    )
  })

  transpilers <- make_package_transpilers("tm", FUN = function(fcn, name) {
    if (!name %in% c("tm_map", "tm_index", "TermDocumentMatrix")) return(NULL)
    transpiler <- eval(bquote_apply(template2, NAME = name))
    list(
      label = sprintf("tm::%s() ~> tm::%s()", name, name),
      transpiler = transpiler
    )
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("tm", "future")
}
