# list_sponsors ---------------------------------------------------------
test_that("list_sponsors returns a data.frame or is NULL.", {
  expect_true((is.null(list_sponsors()) ||
                 ("data.frame" %in% class(list_sponsors()))))
})

test_that("list_sponsors rejects bad input parameters", {
  expect_error(list_sponsors(party_id = "a"))
  expect_error(list_sponsors(party_id = -1))
  expect_error(list_sponsors(party_id = TRUE))
  expect_error(list_sponsors(party_id = c(1,3)))
  expect_error(list_sponsors(party_id = list(a=1, b=2)))
  
  expect_error(list_sponsors(vb = "a"))
  expect_error(list_sponsors(vb = -1))
  expect_error(list_sponsors(vb = c(2,3)))
  expect_error(list_sponsors(vb = list(a=1, b=2)))
  
  expect_error(list_sponsors(rq = "a"))
  expect_error(list_sponsors(rq = -1))
  expect_error(list_sponsors(rq = c(2,3)))
  expect_error(list_sponsors(rq = list(a=1, b=2)))
})
