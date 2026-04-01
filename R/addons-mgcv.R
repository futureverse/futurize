# mgcv::bam(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   mgcv::bam(..., cluster = cl)
# })
#
append_transpilers_for_mgcv <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'mgcv' functions requires R (>= 4.4.0)", getRversion()))
  }

  transpilers <- make_package_transpilers("mgcv", FUN = function(fcn, name) {
    if ("cluster" %in% names(formals(fcn))) {
      transpiler <- make_futurize_for_makeClusterFuture(
        args = list(
          cluster = quote(cl)
        ),
        defaults = list(label = sprintf("fz:mgcv::%s", name))
      )
      
      list(
        label = sprintf("mgcv::%s() ~> mgcv::%s(..., parallel = TRUE)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("mgcv", "future")
}
