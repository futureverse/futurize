# bumphunter::bumphunter(mat, design, chr, pos, ...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   bumphunter::bumphunter(mat, design, chr, pos, ...)
# }))
#
# The bumphunter functions parallelize via 'foreach() %dorng% { ... }'
# using whatever foreach backend is registered. Parallel RNG is
# handled by 'doRNG', which sets the RNG state at the beginning of each
# iteration. Because of this, futurize() does not default to
# 'seed = TRUE'; if set, the future-generated RNG streams would be
# overwritten by doRNG anyway.
#
append_transpilers_for_bumphunter <- function() {
  ## These bumphunter functions call 'foreach() %dorng% { ... }'
  names <- c(
    "bumphunter",
    "bumphunterEngine",
    "smoother"
  )

  ns <- getNamespace("bumphunter")
  names <- names[vapply(names, FUN = exists, mode = "function", envir = ns, inherits = TRUE, FUN.VALUE = NA)]

  ## Use lapply() rather than a for() loop, so that each transpiler
  ## gets its own 'name', because 'defaults' is evaluated lazily
  transpilers <- lapply(names, FUN = function(name) {
    defaults <- list(label = sprintf("fz:bumphunter::%s-%%d", name))
    list(
      label = sprintf("bumphunter::%s() ~> bumphunter::%s()", name, name),
      transpiler = make_futurize_for_doFuture(defaults = defaults)
    )
  })
  names(transpilers) <- names

  transpilers <- list(transpilers)
  names(transpilers) <- "bumphunter"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("bumphunter", "doFuture")
}
