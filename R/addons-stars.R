# stars::st_apply(X, MARGIN, FUN, ...) =>
#
# local({
#   ## This will be automatically consumed and removed by 'future.apply'
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   ## Protect against 'stars' crude setting of future.globals.maxSize
#   ...future_oopts <- options(future.globals.maxSize = getOption("future.globals.maxSize"))
#   on.exit({
#     options(...future_oopts)
#     options(future.disposable = NULL)
#   })
#   stars::st_apply(X, MARGIN, FUN, ..., FUTURE = TRUE)
# })
#
append_transpilers_for_stars <- function() {
  template <- bquote_compile(
   local({
      ## This will be automatically consumed and removed by 'future.apply'
      options(future.disposable = structure(.(OPTS), dispose = FALSE))
      ## Protect against 'stars' crude setting of future.globals.maxSize
      ...future_oopts <- options(future.globals.maxSize = getOption("future.globals.maxSize"))
      on.exit({
        options(...future_oopts)
        options(future.disposable = NULL)
      })
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("stars", FUN = function(fcn, name) {
    if ("FUTURE" %in% names(formals(fcn))) {
      defaults <- list(
        future.label = sprintf("fz:stars::%s-%%d", name)
      )
      list(
        label = sprintf("stars::%s() ~> stars::%s(..., FUTURE = TRUE)", name, name),
        transpiler = make_futurize_for_future.apply(
          defaults = defaults,
          args = list(FUTURE = TRUE),
          template = template
        )
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("stars", "future.apply")
}
