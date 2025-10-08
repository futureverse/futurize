.package <- new.env(parent = emptyenv())
.package[[".futurize"]] <- TRUE

## covr: skip=all
#' @importFrom utils packageVersion
.onLoad <- function(libname, pkgname) {
  ## R CMD build
  register_vignette_engine_during_build_only(pkgname)
  
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

  register_all_transpilers()
} ## .onLoad()
