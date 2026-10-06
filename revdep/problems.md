# progressify (0.2.0)

* GitHub: <https://github.com/futureverse/progressify>
* Email: <mailto:henrikb@braju.com>

Run `revdepcheck::revdep_details(, "progressify")` for more info

## Newly broken

*   checking tests ...
     ```
     ...
       Running ‘test-progressify-foreach.R’
       Running ‘test-progressify-furrr.R’
       Running ‘test-progressify-future.apply.R’
       Running ‘test-progressify-futurize-base.R’
       Running ‘test-progressify-futurize-crossmap.R’
       Running ‘test-progressify-futurize-foreach.R’
       Running ‘test-progressify-futurize-plyr.R’
      ERROR
     Running the tests in ‘tests/test-progressify-futurize-plyr.R’ failed.
     Last 13 lines of output:
       [21:31:44.790] |  :  .  |  :  .  |  Function located in: 'base'
       [21:31:44.790] |  :  .  |  :  .  Locate function ... done
       [21:31:44.790] |  :  .  |  :  parse_call() ... done
       [21:31:44.790] |  :  .  |  :  Position of call to be transpiled in expression: c(3, 2, 1)
       [21:31:44.790] |  :  .  |  :  withCallingHandlers
       [21:31:44.790] |  :  .  |  Finding call to be transpiled ... done
       [21:31:44.791] |  :  .  |  Locating 'progressify::built-in' transpiler for base::withCallingHandlers() of class 'function' ...
       [21:31:44.791] |  :  .  |  :  Namespaces registered with progressify(): 'base', 'boot', 'crossmap', 'future.apply', 'fwb', 'purrr', 'furrr', 'partykit', 'plyr', 'sandwich', 'stats', 'foreach', 'doFuture', 'lme4', 'SimDesign'
       Error in get_transpiler(expr, envir = envir, type = type, what = what,  : 
         Do not know how to progressify function: withCallingHandlers()
       Calls: <Anonymous> -> source -> withVisible -> eval -> eval -> main -> testme_run_test -> source -> withVisible -> eval -> eval -> eval -> eval -> progressify -> transpile -> get_transpiler
       [21:31:44.796] |  :  .  |  Locating 'progressify::built-in' transpiler for base::withCallingHandlers() of class 'function' ... done
       [21:31:44.796] |  :  .  get_transpiler() ... done
       [21:31:44.796] |  :  get_transpiler() ... done
       Execution halted
     ```

