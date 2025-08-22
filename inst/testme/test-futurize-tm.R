if (requireNamespace("tm")) {
library(futurize)
library(tm)
data(crude)

plan(multisession)

# -------------------------------------------------------------------------
# tm_filter() / tm_index()
# -------------------------------------------------------------------------
a0 <- tm_filter(crude, FUN = function(x) any(grep("co[m]?pany", content(x))))
a1 <- tm_filter(crude, FUN = function(x) any(grep("co[m]?pany", content(x)))) |> futurize()

# -------------------------------------------------------------------------
# tm_map()
# -------------------------------------------------------------------------
## Use wrapper to apply character processing function
a0 <- tm_map(crude, content_transformer(tolower))
a1 <- tm_map(crude, content_transformer(tolower)) |> futurize()
stopifnot(all.equal(a0, a1), identical(a0, a1))

## Generate a custom transformation function which takes the heading as new content
headings <- function(x) {
  PlainTextDocument(meta(x, "heading"),
                    id = meta(x, "id"),
                    language = meta(x, "language"))
}                    
b0 <- tm_map(crude, headings)
b1 <- tm_map(crude, headings) |> futurize()
stopifnot(all.equal(a0, a1), identical(a0, a1))



plan(sequential)
} ## if (requireNamespace("tm"))
