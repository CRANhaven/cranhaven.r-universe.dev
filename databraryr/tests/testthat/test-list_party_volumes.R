# list_party_volumes ---------------------------------------------------------
test_that("list_party_volumes returns a data frame or is NULL.", {
  expect_true((is.null(list_party_volumes()) ||
                 ("data.frame" %in% class(list_party_volumes()))))
})

test_that("list_party rejects bad input parameters", {
  expect_error(list_party_volumes(party_id = "a"))
  expect_error(list_party_volumes(party_id = -1))
  expect_error(list_party_volumes(party_id = TRUE))
  expect_error(list_party_volumes(party_id = c(1,3)))
  expect_error(list_party_volumes(party_id = list(a=1, b=2)))
  
  expect_error(list_party_volumes(vb = "a"))
  expect_error(list_party_volumes(vb = -1))
  expect_error(list_party_volumes(vb = c(2,3)))
  expect_error(list_party_volumes(vb = list(a=1, b=2)))
  
  expect_error(list_party_volumes(rq = "a"))
  expect_error(list_party_volumes(rq = -1))
  expect_error(list_party_volumes(rq = c(2,3)))
  expect_error(list_party_volumes(rq = list(a=1, b=2)))
})
