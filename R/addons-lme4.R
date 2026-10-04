# lme4::allFit(...) =>
#
# local({
#   ## This will be automatically consumed and removed by 'future.apply'
#   options(future.disposable = structure(<future options>, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   lme4::allFit(..., parallel = "future")
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
  if (packageVersion("lme4") >= "2.0-6") {
    transpilers <- make_package_transpilers("lme4", FUN = function(fcn, name) {
      if ("parallel" %in% names(formals(fcn))) {
        ## WORKAROUND: 'future.disposable' options override the future.*
        ## arguments that 'lme4' passes to future_lapply()
        defaults <- list(future.label = sprintf("fz:lme4::%s-%%d", name))
        if (name %in% c("allFit", "influence.merMod", "profile.merMod")) {
          defaults$future.packages <- "lme4"
        }
        if (name %in% c("bootMer", "profile.merMod")) {
          defaults$future.seed <- TRUE
        }

        list(
          label = sprintf("lme4::%s() ~> lme4::%s(..., parallel = \"future\")", name, name),
          transpiler = make_futurize_for_future.apply(
            defaults = defaults,
            args = list(parallel = "future")
          )
        )
      }
    })

    append_transpilers("futurize::add-on", transpilers)

    ## Return required packages
    return(c("lme4", "future.apply"))
  }

  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'lme4' (< 2.0-6) functions requires R (>= 4.4.0)", getRversion()))
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
