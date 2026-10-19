# terra::focal(x, w, fun, ..., cores = 1) =>
# terra::tile_apply(x, fun, cores = 1, ...) =>
#
# local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   terra::focal(x, w, fun, ..., cores = "future")
# })
#
# terra::app(x, fun, ...) =>
# terra::lapp(x, fun, ...) =>
# terra::predict(object, model, ...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   terra::app(x, fun, ..., cores = cl)
# })
#
append_transpilers_for_terra <- function() {
  transpilers <- make_package_transpilers("terra", FUN = function(fcn, name) {
    ## focal() and tile_apply() support cores = "future"
    if (name %in% c("focal", "tile_apply")) {
      defaults <- list(
        future.seed = TRUE,
        future.label = sprintf("fz:terra::%s-%%d", name)
      )
      inner <- make_futurize_for_future.apply(
        defaults = defaults,
        args = list(cores = "future")
      )
      transpiler <- function(expr, options = NULL) {
        if (utils::packageVersion("terra") < "1.9.25") {
          stop(sprintf("You are running terra %s, but futurization of 'terra' functions requires terra (>= 1.9-25)", utils::packageVersion("terra")))
        }
        inner(expr, options = options)
      }

      list(
        label = sprintf("terra::%s() ~> terra::%s(..., cores = \"future\")", name, name),
        transpiler = transpiler
      )
    } else if (name %in% c("app", "lapp", "predict")) {
      ## app(), lapp(), and predict() accept argument 'cores', which
      ## takes any parallel 'cluster' object.
      list(
        label = sprintf("terra::%s() ~> terra::%s(..., cores = cl)", name, name),
        transpiler = make_futurize_for_makeClusterFuture(
          args = list(cores = quote(cl)),
          defaults = list(
            seed = TRUE,
            label = sprintf("fz:terra::%s-%%d", name)
          )
        )
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("terra", "future", "future.apply")
}
