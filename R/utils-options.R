#' Options used by futurize
#'
#' Below are the \R options and environment variables that are used by the
#' \pkg{futurize} package and packages enhancing it.\cr
#' \cr
#' _WARNING: Note that the names and the default values of these options may
#'  change in future versions of the package.  Please use with care until
#'  further notice._
#'
#' @section Packages must not change futurize options:
#'
#' Just like for other R options, as a package developer you must _not_ change
#' any of the below `futurize.*` options.  Only the end-user should set these.
#' If you find yourself having to tweak one of the options, make sure to
#' undo your changes immediately afterward.
#'
#' @section Options for debugging:
#' \describe{
#'  \item{\option{futurize.debug}:}{(logical) If `TRUE`, extensive debug messages are generated. (Default: `FALSE`)}
#' }
#'
#' @section Options for controlling futurization:
#' \describe{
#'  \item{\option{futurize.enable}:}{(logical) If `TRUE` (default),
#'    `futurize()` transpilation will be applied, otherwise not.}
#' }
#'
#' @section Environment variables that set R options:
#' All of the above \R \option{futurize.*} options can be set by corresponding
#' environment variable \env{R_FUTURIZE_*} _when the \pkg{futurize} package is
#' loaded_. This means that those environment variables must be set before
#' the \pkg{futurize} package is loaded in order to have an effect.
#' For example, if `R_FUTURIZE_DEBUG=true`, then option
#' \option{futurize.debug} is set to `TRUE` (logical).
#'
#' @seealso
#' To set \R options or environment variables when \R starts (even before the \pkg{futurize} package is loaded), see the \link[base]{Startup} help page.  The \href{https://cran.r-project.org/package=startup}{\pkg{startup}} package provides a friendly mechanism for configuring \R's startup process.
#'
#' @aliases
#' futurize.options 
#'
#' futurize.debug
#' futurize.enable
#'
#' R_FUTURIZE_DEBUG
#' R_FUTURIZE_ENABLE
#'
#' @name zzz-futurize.options 
NULL


update_package_option <- import_future("update_package_option")

## Set future options based on environment variables
update_package_options <- function(debug = FALSE) {
  update_package_option("futurize.enable", mode = "logical", default = TRUE, debug = debug)
}

