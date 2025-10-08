#' Transpile an R expression
#'
#' @param expr An \R expression, typically a function call to transpile.
#'
#' @param options (optional) Named options for the transpilation.
#' 
#' @param when If TRUE (default), the expression is transpiled, otherwise not.
#'
#' @param eval If TRUE (default), the transpiled expression is evaluated,
#' other it is returned.
#'
#' @param envir The environment where the expression should be evaluated.
#'
#' @param flavor Flavor of the transpiler to use.
#'
#' @param unwrap (optional) A list of functions that should be considered
#' wrapping function, that the transpiler should unwrap ("enter"). This
#' Allows us to transpile expressions within `{ ... }` and `local( ... )`.
#'
#' @returns
#' Returns the value of the evaluated expression `expr` if `eval = TRUE`,
#' otherwise the transpiled expression.
#'
#' @keywords internal
transpile <- function(expr, options = list(...), ..., when = TRUE, eval = TRUE, envir = parent.frame(), flavor = "built-in", what = "transpile", unwrap = list(base::`{`, base::`(`, base::local, base::I, base::identity), debug = FALSE) {
  if (debug) {
    mdebug_push("transpile() ...")
    on.exit(mdebug_pop())
  }

  stopifnot(
    is.logical(when), length(when) == 1L, !is.na(when)
  )

  ## Don't transpile, i.e. evaluate as-is?
  if (!when) {
    if (eval) {
      if (debug) mdebug("Evaluate call expression")
      return(eval(expr, envir = envir))
    } else {
      if (debug) mdebug("Return call expression")
      return(expr)
    }
  }
  
  repeat {
    ## 1a. Get a matching transpiler
    transpiler <- get_transpiler(expr, envir = envir, flavor = flavor, what = what, unwrap = unwrap, debug = debug)
  
    transpile <- transpiler[["transpiler"]]

    ## 1b. If not a nested transpiler function, we're done here
    if (!inherits(transpile, "transpiler")) break

    ## 1c. Generate transpiled expression of nested transpiler
    expr <- local({
      if (debug) mdebug_push("Apply nested transpiler ...")
      on.exit(mdebug_pop())
      if (debug) mprint(expr)
      parts <- as.list(expr)
      parts$eval <- FALSE
      expr2 <- as.call(parts)
      expr <- eval(expr2, envir = envir)
      if (debug) mprint(expr)
      expr
    })
  }


  ## 2. Transpile
  if (debug) {
    mdebug_push("Transpile call expression ...")
  }

  expr_transpiled <- transpile(expr, options = options)
  if (debug) {
    mprint(expr_transpiled)
    mdebug_pop()
  }


  ## 3. Evaluate or return transpiled expression?
  if (eval) {
    if (debug) mdebug("Evaluate transpiled call expression")
    eval(expr_transpiled, envir = envir)
  } else {
    if (debug) mdebug("Return transpiled call expression")
    expr_transpiled
  }
} ## transpile()
class(transpile) <- c("transpiler", class(transpile))
