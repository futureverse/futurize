# mlr3tuning::tune(tuner, ...) =>
#
# local({
#   ## This will be automatically consumed and removed by 'future.apply'
#   options(future.disposable = structure(<future options>, dispose = FALSE))
#   ## Make sure 'mlr3' parallelizes via futures, even if mirai daemons
#   ## have been set up for the 'mlr3' compute profile
#   ...future_oopts <- options(mlr3.mirai_parallelization = ".futurize-no-mirai")
#   on.exit({
#     options(...future_oopts)
#     options(future.disposable = NULL)
#   })
#   {
#     ...future_tuner <- tuner
#     if (inherits(...future_tuner, "TunerAsync")) stop(..., call. = FALSE)
#   }
#   mlr3tuning::tune(tuner = ...future_tuner, ...)
# })
#
# Ditto for mlr3tuning::tune_nested(...).
#
# Batch tuners (e.g. tnr("random_search")) evaluate each batch of
# hyperparameter configurations via mlr3::benchmark(), which in turn
# parallelizes via future.apply::future_mapply(). See addons-mlr3.R for
# details. In contrast, asynchronous tuners (e.g.
# tnr("async_random_search")) run on 'rush' workers, which do not use
# futures. Since the type of tuner is only known at run time, the
# transpiled code asserts that it is not an asynchronous tuner.
#
append_transpilers_for_mlr3tuning <- function() {
  ## Evaluate argument 'tuner' once, and assert it is not an async tuner
  make_rewrite <- function(fcn, name) {
    force(fcn)
    force(name)
    function(expr) {
      ## If the call cannot be matched, e.g. because of an unknown
      ## argument, leave it as is, and let the function itself signal
      ## the error when called
      call <- tryCatch(match.call(fcn, expr), error = function(e) NULL)
      if (is.null(call)) return(list(expr = expr))
      tuner <- call[["tuner"]]
      if (is.null(tuner)) return(list(expr = expr))
      call[["tuner"]] <- as.symbol("...future_tuner")
      msg <- sprintf("futurize() does not support asynchronous tuners (TunerAsync) in mlr3tuning::%s(), because they run on 'rush' workers, which do not use futures. Use a batch tuner, e.g. tnr(\"random_search\"), instead", name)
      prologue <- bquote({
        ...future_tuner <- .(tuner)
        if (inherits(...future_tuner, "TunerAsync")) stop(.(msg), call. = FALSE)
      })
      list(expr = call, prologue = prologue)
    }
  }

  transpilers <- make_package_transpilers("mlr3tuning", FUN = function(fcn, name) {
    if (name %in% c("tune", "tune_nested")) {
      defaults <- list(
        future.label = sprintf("fz:mlr3tuning::%s-%%d", name)
      )
      list(
        label = sprintf("mlr3tuning::%s() ~> mlr3tuning::%s()", name, name),
        transpiler = make_futurize_for_mlr3(
          defaults = defaults,
          rewrite = make_rewrite(fcn, name)
        )
      )
    }
  }, s3methods = FALSE)

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("mlr3tuning", "mlr3", "future.apply")
}
