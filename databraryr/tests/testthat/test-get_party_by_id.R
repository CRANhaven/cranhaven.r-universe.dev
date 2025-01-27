# get_party_by_id ---------------------------------------------------------
test_that("get_party_by_id returns a list or is NULL.", {
  expect_true((is.null(get_party_by_id()) ||
                 ("list" %in% class(get_party_by_id()))))
})

test_that("get_party_by_id rejects bad input parameters", {
  expect_error(get_party_by_id(party_id = "a"))
  expect_error(get_party_by_id(party_id = -1))
  expect_error(get_party_by_id(party_id = c(2,3)))
  expect_error(get_party_by_id(party_id = TRUE))

  expect_error(get_party_by_id(parents_children_access = "a"))
  expect_error(get_party_by_id(parents_children_access = -1))
  expect_error(get_party_by_id(parents_children_access = c(2,3)))

  expect_error(get_party_by_id(vb = "a"))
  expect_error(get_party_by_id(vb = -1))
  expect_error(get_party_by_id(vb = c(2,3)))
  
  expect_error(get_party_by_id(rq = "a"))
  expect_error(get_party_by_id(rq = -1))
  expect_error(get_party_by_id(rq = c(2,3)))
  expect_error(get_party_by_id(rq = list(a=1, b=2)))
})
