.package <- new.env()

## covr: skip=all
#' @importFrom utils packageVersion
.onLoad <- function(libname, pkgname) {
  .package[["version"]] <- packageVersion(pkgname)

  update_package_option("futurize.debug", mode = "logical")
  debug <- isTRUE(getOption("futurize.debug"))

  if (debug) {
    envs <- Sys.getenv()
    envs <- envs[grep("R_FUTURIZE_", names(envs), fixed = TRUE)]
    envs <- sprintf("- %s=%s", names(envs), sQuote(envs))
    mdebug(paste(c("Futurize-specific environment variables:", envs), collapse = "\n"))
  }

  ## Set future options based on environment variables
  update_package_options(debug = debug)
} ## .onLoad()
