pkgs <- futurize::futurize_supported_packages()
print(pkgs)

for (pkg in c(pkgs, "future", "aNonExistingPackage")) {
  if (requireNamespace(pkg)) {
    cat(sprintf("Package %s:\n", pkg))
    fcns <- tryCatch({
      futurize::futurize_supported_functions(pkg)
    }, error = identity)
    print(fcns)
  }
}
