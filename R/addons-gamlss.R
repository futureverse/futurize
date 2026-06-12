# gamlss::gamlssCV(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   gamlss::gamlssCV(..., parallel = "snow", ncpus = 2L, cl = cl)
# })
#
append_transpilers_for_gamlss <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'gamlss' functions requires R (>= 4.4.0)", getRversion()))
  }

  ## Functions that do NOT respect a user-provided 'cl' argument:
  ## stepGAIC(), stepGAICAll.A(), stepGAICAll.B(), stepTGD(),
  ## stepTGDAll.A() always create their own cluster via
  ## parallel::makeForkCluster() regardless of the 'cl' value.
  ##
  ## Functions that use parallel::clusterEvalQ(), which is not
  ## supported: chooseDist(), chooseDistPred().
  skip <- c("stepGAIC", "stepGAICAll.A", "stepGAICAll.B",
            "stepTGD", "stepTGDAll.A",
            "chooseDist", "chooseDistPred")

  transpilers <- make_package_transpilers("gamlss", FUN = function(fcn, name) {
    if (name %in% skip) return(NULL)
    if (all(c("parallel", "ncpus", "cl") %in% names(formals(fcn)))) {
      transpiler <- make_futurize_for_makeClusterFuture(
        defaults = list(
          seed = (name == "gamlssCV"),
          packages = "gamlss",
          label = sprintf("fz:gamlss::%s", name)
        ),
        args = list(
          parallel = "snow",
          ncpus = 2L,   ## only used for test ncpus > 1
          cl = quote(cl)
        )
      )

      list(
        label = sprintf("gamlss::%s() ~> gamlss::%s(..., parallel = TRUE)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("gamlss", "future")
}
