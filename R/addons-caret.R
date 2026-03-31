# caret::train(...) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   caret::train(...)
# })
#
append_transpilers_for_caret <- function() {
  transpilers <- make_package_transpilers("caret", FUN = function(fcn, name) {
    ## nnnControl()
    if ("allowParallel" %in% names(formals(fcn))) {
      if (name == "nearZeroVar") {
        list(
          label = sprintf("caret::%s() ~> caret::%s()", name, name),
          transpiler = make_futurize_for_doFuture(
            defaults = list(
              seed = TRUE,
              label = sprintf("fz:caret::%s-%%d", name)
            ),
            args = list(foreach = TRUE)
          )
        )
      }
    } else {
      ## nnn() -> nnnControl()
      nameControl <- sprintf("%sControl", name)
      if (exists(nameControl, mode = "function", envir = getNamespace("caret"), inherits = FALSE)) {
        fcnControl <- get(nameControl, mode = "function", envir = getNamespace("caret"), inherits = FALSE)
        if ("allowParallel" %in% names(formals(fcnControl))) {
          list(
            label = sprintf("caret::%s() ~> caret::%s()", name, name),
            transpiler = make_futurize_for_doFuture(
              defaults = list(
                seed = TRUE,
                label = sprintf("fz:caret::%s-%%d", name)
              )
            )
          )
        }
      }
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("caret", "doFuture")
}
