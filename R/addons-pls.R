# pls::mvr(...) =>
#
# local({
#   cl <- future::makeClusterFuture(<future arguments>)
#   old_parallel <- pls::pls.options("parallel")
#   on.exit(pls::pls.options(old_parallel))
#   pls::pls.options(parallel = cl)
#   pls::mvr(...)
# })
#
append_transpilers_for_pls <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'pls' functions requires R (>= 4.4.0)", getRversion()))
  }

  template_pls <- bquote_compile(
    local({
      cl <- do.call(.(CALL), args = .(OPTS))
      old_parallel <- pls::pls.options("parallel")
      on.exit(pls::pls.options(old_parallel))
      pls::pls.options(parallel = cl)
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("pls", FUN = function(fcn, name) {
    if (name %in% c("mvr", "plsr", "pcr", "cppls", "crossval")) {
      seed <- name == "crossval"
      transpiler <- make_futurize_for_makeClusterFuture(
        template = template_pls,
        defaults = list(
          seed = seed,
          label = sprintf("fz:pls::%s", name)
        )
      )

      list(
        label = sprintf("pls::%s() ~> pls.options(parallel = cl); pls::%s()",  name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("pls", "future")
}
