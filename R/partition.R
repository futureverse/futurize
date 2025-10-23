#' Partition futures into equivalent classes
#'
#' @param x A container of futures, e.g. a list.
#'
#' @param by Named elements of the futures to partition futures by.
#'
#' @param \ldots Currently not used.
#'
#' @param scheduling Average number of futures ("chunks") per worker.
#'        If `0.0`, then a single future is used to process all elements
#'        of `X`.
#'        If `1.0` or `TRUE`, then one future per worker is used.
#'        If `2.0`, then each worker will process two futures
#'        (if there are enough elements in `X`).
#'        If `Inf` or `FALSE`, then one future per element of
#'        `X` is used.
#'        Only used if `future.chunk.size` is `NULL`.
#'
#' @param chunk_size The average number of elements per future ("chunk").
#'        If `Inf`, then all elements are processed in a single future.
#'        If `NULL`, then argument `future.scheduling` is used.
#'
#' @return
#' Returns ...
#'
#' @keywords internal
#' @export
partition <- function(x, ...) {
  UseMethod("partition")
}

#' @rdname partition
#' @importFrom future.apply future_lapply
#' @importFrom future nbrOfWorkers
#' @export
partition.list <- local({
  makeChunks <- import_future.apply("makeChunks")

  function(x, by = "expr", scheduling = 1.0, chunk_size = NULL, ...) {
    fs <- x
  
    ## For now, group only by 'expr'
    ## NOTE: This is the most common use case, because that covers
    ## all map-reduce calls. We could go even smarter, by generalizing
    ## to grouping by (expr, globals, packages, stdout, ...)
    by <- match.arg(by, choices = "expr")
    
    n <- length(fs)
    
    ## Nothing to do?
    if (n <= 1) return(fs)
    
    ## Extract subset of lazy futures
    is_lazy_future <- vapply(fs, FUN = function(f) {
      inherits(f, "Future") && f[["lazy"]]
    }, FUN.VALUE = NA)
    stopifnot(all(is_lazy_future))
  
    ## Group by 'expr'
    idxs <- seq_len(n)
    groups <- vector("list", length = length(by))
    names(groups) <- by
    for (ii in seq_along(by)) {
      field <- by[[ii]]
      values <- vapply(fs, FUN.VALUE = NA_character_, FUN = function(f) {
        value <- f[[field]]
        digest::digest(value)
      })
      factors <- as.factor(values)
      groups[[ii]] <- split(idxs, factors, drop = FALSE)
    }
  
    ## The following code assumes that we group only by a single field
    stopifnot(length(by) == 1L, length(groups) == 1L)
  
    group <- groups[[1]]
    fs_groups <- lapply(group, FUN = function(idxs) fs[idxs])
  
    ## Assumpt for now is that there is only a single group
    stopifnot(length(fs_groups) == 1L)
    fs_group <- fs_groups[[1]]
  
    ## Chunk up futures according to load balance parameters
    chunks <- makeChunks(length(fs_group),
                          nbrOfWorkers = nbrOfWorkers(),
                          future.scheduling = scheduling,
                          future.chunk.size = chunk_size)
    fs_chunks <- lapply(chunks, FUN = function(idxs) fs_group[idxs])
  
    fs_chunks <- lapply(fs_chunks, FUN = function(fs_chunk) {
      packages <- unique(unlist(lapply(fs_chunk, FUN = function(f) f[["packages"]])))
      globals <- lapply(fs_chunk, FUN = function(f) f[["globals"]])
      
      ## Look for identical globals (among the 'globals')
      names <- lapply(globals, FUN = names)
      unames <- unique(names)
      pnames <- Reduce(intersect, unames)
      
      ## Check which of these globals are identical across futures
      is_constant <- vapply(pnames, FUN.VALUE = NA, FUN = function(name) {
        values <- lapply(globals, FUN = function(g) g[[name]])
        if (length(values) == 1L) return(TRUE)
        Reduce(identical, values)
      })
      globals_constant <- globals[[1]][pnames[is_constant]]
      globals_unique <- lapply(globals, FUN = function(g) {
        keep <- setdiff(names(g), pnames[is_constant])
        g[keep]
      })
  
      fs_first <- fs_chunk[[1]]
      expr <- fs_first[["expr"]]
      expr <- bquote({
        genv <- environment()
        
        ## Assign constant globals
        for (name in names(globals_constant)) {
          assign(name, globals_constant[[name]], envir = genv, inherits = FALSE)
        }
        lapply(globals_unique, FUN = function(chunk) {
          ## Assign unique globals
          for (name in names(chunk)) {
            assign(name, chunk[[name]], envir = genv, inherits = FALSE)
          }
          .(expr)
        })
      })
  
      ## Use 'stdout', 'condition' etc. from the first future
      stdout <- fs_first[["stdout"]]
      conditions <- fs_first[["conditions"]]
      seed <- fs_first[["seed"]]
      
      globals_chunk <- list(globals_constant = globals_constant, globals_unique = globals_unique)
      future(expr, substitute = FALSE, globals = globals_chunk, packages = packages, stdout = stdout, conditions = conditions, seed = seed, lazy = TRUE)
    })
    
    fs_chunks
  } ## partition() for list:s
})
