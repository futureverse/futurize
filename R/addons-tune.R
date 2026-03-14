# tune::tune_grid(...) =>
#
# with_tune_shim({
#   options(future.disposable = structure(<future arguments>, dispose = FALSE))
#   on.exit(options(future.disposable = NULL), add = TRUE, after = TRUE)
#   tune::tune_grid(...)
# })

append_transpilers_for_tune <- function() {
  template <- bquote_compile(
    local({
      with_tune_shim <- get("with_tune_shim", envir = asNamespace("futurize"))
      with_tune_shim({
        options(future.disposable = structure(.(OPTS), dispose = FALSE))
        on.exit(options(future.disposable = NULL), add = TRUE, after = TRUE)
        .(EXPR)
      })
    })
  )

  transpiler <- function(expr, options = NULL) {
    opts <- make_options_for_doFuture(options, defaults = list(seed = TRUE), wrap = FALSE)
    bquote_apply(template,
      OPTS = opts,
      EXPR = expr
    )
  }

  transpilers <- make_package_transpilers("tune", FUN = function(fcn, name) {
    ## Skip control functions themselves
    if (grepl("^control_", name)) return(NULL)

    ## Find matching control function with 'allow_par' argument
    control_names <- unique(c(
      sprintf("control_%s", sub("^(tune|fit)_", "", name)),
      sprintf("control_%s", name)
    ))

    ns <- getNamespace("tune")
    for (control_name in control_names) {
      if (exists(control_name, mode = "function", envir = ns, inherits = FALSE)) {
        fcnControl <- get(control_name, mode = "function", envir = ns, inherits = FALSE)
        if ("allow_par" %in% names(formals(fcnControl))) {
          return(list(
            label = sprintf("tune::%s() ~> tune::%s()", name, name),
            transpiler = transpiler
          ))
        }
      }
    }

    NULL
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("tune", "future.apply")
}


## Temporarily override tune::choose_framework() to always return "future",
## regardless of number of registered future and mirai workers. If not done,
## it will return "sequential" if there's only one worker register, and
## "mirai" if there is two or more mirai workers, regardless of the number
## of future workers. Also, if not done, it would trigger loading of the
## 'mirai' package, if not loaded.
with_tune_shim <- local({
  .unlockBinding <- unlockBinding ## Too please 'R CMD check'
  .shim <- function(...) "future"
  .ns <- NULL
  .original <- NULL
  
  function(expr, envir = parent.frame()) {
    expr <- substitute(expr)

    if (is.null(.ns)) .ns <<- asNamespace("tune")
    if (is.null(.original)) .original <<- tune::choose_framework()
    
    .unlockBinding("choose_framework", env = .ns)
    assign("choose_framework", .shim, envir = .ns, inherits = FALSE)
    lockBinding("choose_framework", env = .ns)
    on.exit({
      .unlockBinding("choose_framework", env = .ns)
      assign("choose_framework", .original, envir = .ns, inherits = FALSE)
      lockBinding("choose_framework", env = .ns)
    }, add = TRUE, after = TRUE)
    
    eval(expr, envir = envir)    
  }
})