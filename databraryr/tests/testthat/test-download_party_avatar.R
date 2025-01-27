test_that("download_party_avatar rejects bad input parameters", {
  expect_error(download_party_avatar(party_id = -1))
  expect_error(download_party_avatar(party_id = "a"))
  expect_error(download_party_avatar(party_id = TRUE))

  expect_error(download_party_avatar(show_person_info = -1))
  expect_error(download_party_avatar(show_person_info = 3))
  expect_error(download_party_avatar(show_person_info = "a"))
  expect_error(download_party_avatar(show_person_info = list(a=1, b=2)))
  
  expect_error(download_party_avatar(vb = -1))
  expect_error(download_party_avatar(vb = 3))
  expect_error(download_party_avatar(vb = "a"))
  expect_error(download_party_avatar(vb = list(a=1, b=2)))
  
  expect_error(download_party_avatar(rq = -1))
  expect_error(download_party_avatar(rq = "a"))
  expect_error(download_party_avatar(rq = list(a=1, b=2)))
  expect_error(download_party_avatar(rq = NA))
})
