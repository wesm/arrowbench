test_that("augment_run() works", {
  reason <- "test"
  host_name <- "fake-computer"
  github <- list(
    repository = "https://github.com/conchair/conchair",
    commit = "fake-commit",
    pr_number = 47L
  )

  unaugmented_run <- BenchmarkRun$new(reason = reason, github = NULL)
  withr::with_envvar(
    c(
      "CONBENCH_MACHINE_INFO_NAME" = host_name,
      "CONBENCH_PROJECT_REPOSITORY" = github$repository,
      "CONBENCH_PROJECT_COMMIT" = github$commit,
      "CONBENCH_PROJECT_PR_NUMBER" = github$pr_number
    ),
    { augmented_run <- augment_run(unaugmented_run) }
  )

  expect_equal(unaugmented_run$reason, reason)
  expect_equal(augmented_run$reason, reason)

  expect_null(unaugmented_run$id)
  expect_type(augmented_run$id, "character")

  expect_null(unaugmented_run$machine_info)
  expect_type(augmented_run$machine_info, "list")
  expect_type(augmented_run$machine_info$name, "character")
  expect_equal(augmented_run$machine_info$name, host_name)

  expect_null(unaugmented_run$github)
  expect_equal(augmented_run$github, github)
})


test_that("augment_result() works", {
  stats <- list(data = list(1, 2, 3), unit = "s", times = NULL, time_unit = NULL, iterations = 3)
  host_name <- "fake-computer"
  github <- list(
    repository = "conchair/conchair",
    commit = "fake-commit",
    pr_number = 47L
  )

  unaugmented_result <- BenchmarkResult$new(stats = stats, github = NULL)
  withr::with_envvar(
    c(
      "CONBENCH_MACHINE_INFO_NAME" = host_name,
      "CONBENCH_PROJECT_REPOSITORY" = github$repository,
      "CONBENCH_PROJECT_COMMIT" = github$commit,
      "CONBENCH_PROJECT_PR_NUMBER" = github$pr_number
    ),
    { augmented_result <- augment_result(unaugmented_result) }
  )

  expect_equal(unaugmented_result$timestamp, augmented_result$timestamp)

  expect_equal(unaugmented_result$stats, stats)
  expect_equal(augmented_result$stats, stats)

  expect_null(unaugmented_result$batch_id)
  expect_type(augmented_result$batch_id, "character")

  expect_null(unaugmented_result$machine_info)
  expect_type(augmented_result$machine_info, "list")
  expect_type(augmented_result$machine_info$name, "character")
  expect_equal(augmented_result$machine_info$name, host_name)

  expect_null(unaugmented_result$github)
  expect_equal(augmented_result$github, github)
})


test_that("start_run() works", {
  host_name <- "fake-computer"
  bm_run <- BenchmarkRun$new(
    name = "arrowbench-unit-test: 2z8c9c49a5dc4a179243268e4bb6daa5",
    reason = "arrowbench-unit-test",
    github = list(
      commit = "2z8c9c49a5dc4a179243268e4bb6daa5",
      repository = "https://github.com/conchair/conchair",
      pr_number = 47L
    )
  )

  withr::with_envvar(
    c(CONBENCH_MACHINE_INFO_NAME = host_name),
    started_run <- start_run(run = bm_run)
  )

  expect_identical(started_run$name, bm_run$name)
  expect_identical(started_run$reason, bm_run$reason)
  expect_type(started_run$id, "character")
  expect_identical(started_run$machine_info$name, host_name)
})


test_that("submit_result() works", {
  result_dir <- tempfile("conbench-results-")
  bm_result <- BenchmarkResult$new(
    run_id = "fake-run-id",
    run_name = "arrowbench-unit-test: 2z8c9c49a5dc4a179243268e4bb6daa5",
    run_reason = "arrowbench-unit-test",
    github = list(
      commit = "2z8c9c49a5dc4a179243268e4bb6daa5",
      repository = "https://github.com/conchair/conchair",
      pr_number = 47L
    ),
    stats = list(data = list(1, 2, 3), unit = "s", times = NULL, time_unit = NULL, iterations = 3)
  )

  withr::with_envvar(
    c(CONBENCH_RESULTS_DIR = result_dir, CONBENCH_MACHINE_INFO_NAME = "fake-computer"),
    path <- submit_result(result = bm_result)
  )

  expect_true(file.exists(path))
  payload <- BenchmarkResult$read_json(path)
  expect_identical(payload$run_id, "fake-run-id")
  expect_identical(payload$run_name, bm_result$run_name)
  expect_identical(payload$run_reason, bm_result$run_reason)
  expect_identical(payload$machine_info$name, "fake-computer")
  expect_identical(payload$github, bm_result$github)
})


test_that("finish_run() works", {
  expect_invisible(finish_run())
})
