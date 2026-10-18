# terra::focal(x, w, fun, ..., cores = 1) =>
# terra::tile_apply(x, fun, cores = 1, ...) =>
#
# local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   terra::focal(x, w, fun, ..., cores = "future")
# })
#
append_transpilers_for_terra <- function() {
  transpilers <- make_package_transpilers("terra", FUN = function(fcn, name) {
    ## focal() and tile_apply() support argument cores = "future". Other 'terra'
    ## functions supports futureverse automatically, meaning there is no argument to
    ## specify, e.g. app(), lapp(), predict(). We could add no-op futurize() support
    ## for these for consistency, but that would interfer with terra's API.
    if (name %in% c("focal", "tile_apply")) {
      defaults <- list(
        future.seed = TRUE,
        future.label = sprintf("fz:terra::%s-%%d", name)
      )
      inner <- make_futurize_for_future.apply(
        defaults = defaults,
        args = list(cores = "future")
      )
      ## Note: this version check must run here, at transpile time, and
      ## not at registration time, because errors raised while registering
      ## transpilers (futurize:::transpilers_for_package(action = "make"))
      ## are silently swallowed.
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
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("terra", "future.apply")
}
