pkgs <- futurize::futurize_supported_packages()
print(pkgs)

for (pkg in c(pkgs, "future", "aNonExistingPackage")) {
  cat(sprintf("Package %s:\n", pkg))
  fcns <- tryCatch({
    futurize::futurize_supported_functions(pkg)
  }, error = identity)
  print(fcns)
}

## Assert that there are not clashes between supported packages
pkgs <- futurize::futurize_supported_packages()
for (pkg in rep(pkgs, times = 2L)) {
  cat(sprintf("Package %s:\n", pkg))
  ## futurize_supported_functions() fail if required packages
  ## are not supported
  fcns <- tryCatch({
    futurize::futurize_supported_functions(pkg)
  }, error = identity)
  print(fcns)
}
