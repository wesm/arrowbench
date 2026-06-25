# Arrow R Benchmarks

R benchmark package for Apache Arrow. This fork is part of the Conbench v2
migration path and currently targets branch `v2-conbench-payloads` on
`wesm/arrowbench`.

## Agent workflow

- Commit repository changes before ending the turn unless the user explicitly
  asks not to commit. Keep unrelated user changes out of commits; stage only
  the paths you changed for the task.
- Do not commit downloaded benchmark data, generated payloads, local R library
  state, credentials, reporter tokens, or full environment dumps.
- Do not add tautological content-matching tests that only assert that strings,
  labels, headings, or resource names you just wrote are still present. Tests
  must verify behavior or a meaningful contract: parse structured output when
  possible, exercise code paths, validate rendered artifacts with an external
  consumer, or check invariants that would catch a real regression.

## Conbench v2 migration

- The supported publishing boundary is v2 JSON payload files consumed by the Go
  `conbench` CLI. Do not add legacy Conbench client publishing as a maintained
  path.
- Preserve Buildkite-facing metadata such as run id, run name, run reason,
  repository, commit, pull request number, machine, and benchmark language.
- Keep benchmark execution separate from result submission so Buildkite can
  retain payload artifacts when submission fails.

## Validation

- Prefer focused `R CMD check`, `testthat`, or package test invocations for
  touched R code. Note `ARROWBENCH_TEST_CUSTOM_DUCKDB` controls optional DuckDB
  tests.
- Run `R CMD build` or `R CMD check` when package metadata, exports, or broad
  behavior changes.
- Always run `git diff --check` before committing.
