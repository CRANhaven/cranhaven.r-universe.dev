test_that(
  "Two-stage design optimization runs without error.",
  {
    expect_error(
      optimize_design_twostage(
        print_progress = FALSE,
        nloptr_opts = list(maxeval = 1, algorithm = "NLOPT_LN_SBPLX")),
      NA)
  })

test_that(
  "Single-stage design optimization runs without error.",
  {
    expect_error(
      optimize_design_onestage(
        print_progress = FALSE,
        nloptr_opts = list(maxeval = 1, algorithm = "NLOPT_LN_SBPLX")),
      NA)
  })

