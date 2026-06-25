conbench_results_dir <- function() {
  dir <- Sys.getenv("CONBENCH_RESULTS_DIR", "bench-results")
  if (dir == "") {
    dir <- "bench-results"
  }
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  dir
}

conbench_machine_info <- function() {
  host_name <- Sys.getenv("CONBENCH_MACHINE_INFO_NAME")
  if (host_name == "") {
    host_name <- Sys.info()[["nodename"]]
  }
  if (is.null(host_name) || is.na(host_name) || host_name == "") {
    host_name <- "unknown"
  }
  list(name = unname(host_name))
}

augment_run <- function(run) {
  run <- run$clone(deep = TRUE)
  if (is.null(run$id)) {
    run$id <- uuid::UUIDgenerate()
  }
  if (is.null(run$github)) {
    run$github <- github_info()
  }
  if (is.null(run$name) && !is.null(run$reason)) {
    run$name <- paste(run$reason, run$github$commit, sep = ": ")
  }
  if (is.null(run$machine_info)) {
    run$machine_info <- conbench_machine_info()
  }
  run
}

augment_result <- function(result) {
  result <- result$clone(deep = TRUE)
  if (is.null(result$run_id)) {
    result$run_id <- uuid::UUIDgenerate()
  }
  if (is.null(result$batch_id)) {
    result$batch_id <- uuid::UUIDgenerate()
  }
  if (is.null(result$github)) {
    result$github <- github_info()
  }
  if (is.null(result$machine_info)) {
    result$machine_info <- conbench_machine_info()
  }
  result
}

start_run <- function(run) {
  invisible(augment_run(run))
}

submit_result <- function(result) {
  result <- augment_result(result)
  path <- file.path(conbench_results_dir(), paste0("result-", uuid::UUIDgenerate(), ".json"))
  result$write_json(path)
  message("Wrote Conbench result payload: ", path)
  invisible(path)
}

finish_run <- function(run) {
  invisible(NULL)
}
