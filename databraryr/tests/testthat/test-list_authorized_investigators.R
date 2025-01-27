# list_authorized_investigators ---------------------------------------------------------
test_that("list_authorized_investigators returns a data.frame or is NULL.", {
  expect_true((is.null(list_authorized_investigators()) ||
                 (class(list_authorized_investigators()) == "data.frame")))
})

test_that("list_authorized_investigators rejects bad input parameters", {
  expect_error(list_authorized_investigators(party_id = "a"))
  expect_error(list_authorized_investigators(party_id = -1))
  expect_error(list_authorized_investigators(party_id = TRUE))
  expect_error(list_authorized_investigators(party_id = c(1,3)))
  expect_error(list_authorized_investigators(party_id = list(a=1, b=2)))
  
  expect_error(list_authorized_investigators(vb = "a"))
  expect_error(list_authorized_investigators(vb = -1))
  expect_error(list_authorized_investigators(vb = c(2,3)))
  expect_error(list_authorized_investigators(vb = list(a=1, b=2)))
})

test_that("list_authorized_investigators returns NULL for invalid (non-institutional) party IDs", {
  expect_true(is.null(list_authorized_investigators(party_id = 5)))
})
