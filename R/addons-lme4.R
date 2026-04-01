# lme4::allFit(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   lme4::allFit(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
# lme4:::influence.merMod(...) [via stats::influence()] =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   stats::influence(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_lme4 <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'lme4' functions requires R (>= 4.4.0)", getRversion()))
  }

  transpilers <- make_package_transpilers("lme4", FUN = function(fcn, name) {
    if ("parallel" %in% names(formals(fcn))) {
      defaults <- list(label = sprintf("fz:lme4::%s", name))
      if (name %in% c("allFit", "influence.merMod")) {
        defaults$packages <- "lme4"
      }

      list(
        label = sprintf("lme4::%s() ~> lme4::%s(..., parallel = TRUE)", name, name),
        transpiler = make_futurize_for_makeClusterFuture(defaults = defaults, args = list(
          parallel = "snow",
          ncpus = 2L,   ## only used for test ncpus > 1
          cl = quote(cl)
        ))
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("lme4", "future")
}
