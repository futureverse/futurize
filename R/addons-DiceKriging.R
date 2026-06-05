# DiceKriging::km(..., multistart = N) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   DiceKriging::km(..., multistart = N)
# })
#
# Note: The parallel foreach loop is triggered only when multistart > 1.
# The loop lives in the internal function kmEstimate(), which is called by km().
#
append_transpilers_for_DiceKriging <- function() {
  transpilers <- make_package_transpilers("DiceKriging", FUN = function(fcn, name) {
    ## Only km() triggers the internal foreach %dopar% loop
    if (name != "km") return(NULL)

    list(
      label = "DiceKriging::km() ~> DiceKriging::km() [via doFuture]",
      transpiler = make_futurize_for_doFuture(
        defaults = list(
          label = "fz:DiceKriging::km-%d"
        )
      )
    )
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("DiceKriging", "doFuture")
}
