# list_party_affiliates ---------------------------------------------------------
test_that("list_party_affiliates returns a data frame or is NULL.", {
  expect_true((is.null(list_party_affiliates()) ||
                 ("data.frame" %in% class(list_party_affiliates()))))
})

test_that("list_party rejects bad input parameters", {
  expect_error(list_party_affiliates(party_id = "a"))
  expect_error(list_party_affiliates(party_id = -1))
  expect_error(list_party_affiliates(party_id = TRUE))
  expect_error(list_party_affiliates(party_id = c(1,3)))
  expect_error(list_party_affiliates(party_id = list(a=1, b=2)))

  expect_error(list_party_affiliates(vb = "a"))
  expect_error(list_party_affiliates(vb = -1))
  expect_error(list_party_affiliates(vb = c(2,3)))
  expect_error(list_party_affiliates(vb = list(a=1, b=2)))
  
  expect_error(list_party_affiliates(rq = "a"))
  expect_error(list_party_affiliates(rq = -1))
  expect_error(list_party_affiliates(rq = c(2,3)))
  expect_error(list_party_affiliates(rq = list(a=1, b=2)))
})
