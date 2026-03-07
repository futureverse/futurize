# glmmTMB::confint(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   glmmTMB::confint(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_glmmTMB <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'glmmTMB' functions requires R (>= 4.4.0)", getRversion()))
  }

  template <- bquote_compile(
    local({
      ## WORKAROUND: https://github.com/glmmTMB/glmmTMB/issues/1265
      base_attach <- base::attach # silence R CMD check
      base_attach(list(new_cl = FALSE), name = "glmmTLB:patch")
      on.exit(detach("glmmTLB:patch"))
      
      cl <- do.call(.(CALL), args = .(OPTS))
      oopts <- options(future.ClusterFuture.clusterEvalQ = "error")
      on.exit(options(oopts), add = TRUE)
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("glmmTMB", FUN = function(fcn, name) {
    if (all(c("parallel", "ncpus", "cl") %in% names(formals(fcn)))) {
      list(
        label = sprintf("glmmTMB::%s() ~> glmmTMB::%s(..., parallel = TRUE)", name, name),
        transpiler = make_futurize_for_makeClusterFuture(args = list(
          parallel = "snow",
          ncpus = 2L,   ## only used for test ncpus > 1
          cl = quote(cl)
        ), template = template)
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("glmmTMB", "future")
}
