now <- function(x = Sys.time(), format = "[%H:%M:%OS3] ") {
  ## format(x, format = format) ## slower
  format(as.POSIXlt(x, tz = ""), format = format)
}

## Whether debug output is enabled, which is controlled by the R option
## named after the package, e.g. 'futurize.debug'
isDebugEnabled <- local({
  .opt_name <- sprintf("%s.debug", .packageName)
  function() {
    isTRUE(getOption(.opt_name))
  }
})

debug_indent <- local({
  prefix <- ""
  depth <- 0L
  symbols <- rep(c("|", ":", "."), times = 10L)

  function(delta = 0L) {
    if (delta == 0) return(prefix)
    if (delta > 0) {
      depth <<- depth + 1L
    } else if (delta < 0) {
      depth <<- depth - 1L
      if (depth < 0L) {
        ## Reset before warning, in case the warning is turned into an error
        depth <<- 0L
        prefix <<- ""
        calls <- vapply(sys.calls(), FUN = function(call) {
          paste(deparse(call), collapse = " ")
        }, FUN.VALUE = NA_character_)
        warning(sprintf("[INTERNAL WARNING]: There appears to be one mdebug_pop() too many: %s", paste(calls, collapse = " -> ")), call. = TRUE, immediate. = TRUE)
        return(prefix)
      }
    }
    prefix <<- if (depth == 0) "" else paste(paste(symbols[seq_len(depth)], " "), collapse = "")
  }
})

.debug <- new.env(parent = emptyenv())
.debug$stack <- list()

mdebug_push <- function(..., debug = isDebugEnabled()) {
  if (!debug) return()
  msg <- mdebug(..., debug = debug)
  debug_indent(+1)
  .debug$stack <- c(.debug$stack, msg)
  invisible(msg)
}

mdebugf_push <- function(..., debug = isDebugEnabled()) {
  if (!debug) return()
  msg <- mdebugf(..., debug = debug)
  debug_indent(+1)
  .debug$stack <- c(.debug$stack, msg)
  invisible(msg)
}

# Get or set current stack
mdebug_stack <- function(stack = NULL) {
  if (!is.null(stack)) {
    ## Keep the indentation in sync with the stack
    delta <- length(stack) - length(.debug$stack)
    for (kk in seq_len(abs(delta))) debug_indent(sign(delta))
    .debug$stack <- stack
  }
  invisible(.debug$stack)
}

mdebug_pop <- function(..., debug = isDebugEnabled()) {
  if (!debug) return()
  n <- length(.debug$stack)
  if (n == 0) stop("Called mdebug_pop() on an empty debug stack")
  msg <- .debug$stack[n]
  .debug$stack <- .debug$stack[-n]
  debug_indent(-1)
  mdebug(sprintf("%s done", msg), debug = debug)
}

mdebugf_pop <- function(..., debug = isDebugEnabled()) {
  if (!debug) return()
  n <- length(.debug$stack)
  if (n == 0) stop("Called mdebug_pop() on an empty debug stack")
  msg <- .debug$stack[n]
  .debug$stack <- .debug$stack[-n]
  debug_indent(-1)
  mdebug(sprintf("%s done", msg), debug = debug)
}

mdebug <- function(..., prefix = now(), debug = isDebugEnabled()) {
  if (!debug) return()
  prefix <- paste(prefix, debug_indent(), sep = "")
  msg <- paste(..., sep = "")
  message(sprintf("%s%s", prefix, msg))
  invisible(msg)
}

mdebugf <- function(..., appendLF = TRUE,
                    prefix = now(), debug = isDebugEnabled()) {
  if (!debug) return()
  prefix <- paste(prefix, debug_indent(), sep = "")
  msg <- sprintf(...)
  message(sprintf("%s%s", prefix, msg), appendLF = appendLF)
  invisible(msg)
}

#' @importFrom utils capture.output
mprint <- function(..., appendLF = TRUE, prefix = now(), debug = isDebugEnabled()) {
  if (!debug) return()
  prefix <- paste(prefix, debug_indent(), sep = "")
  message(paste(prefix, capture.output(print(...)), sep = "", collapse = "\n"), appendLF = appendLF)
}

#' @importFrom utils capture.output str
mstr <- function(..., appendLF = TRUE, prefix = now(), debug = isDebugEnabled()) {
  if (!debug) return()
  prefix <- paste(prefix, debug_indent(), sep = "")
  message(paste(prefix, capture.output(str(...)), sep = "", collapse = "\n"), appendLF = appendLF)
}
