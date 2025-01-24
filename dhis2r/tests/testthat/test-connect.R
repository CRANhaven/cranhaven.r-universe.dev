
dhis2_play_connection <- Dhis2r$new(base_url = "https://play.im.dhis2.org/stable-2-40-5/",
                                    username = "admin",
                                    password = "district"
                                    # api_version = "2.39.0.1",
                                    # api_version_position = "before"
                                    )


test_that("Can connect to DHIS2 instance", {
  skip_on_cran()
  skip_if_offline()
  expect_equal(dhis2_play_connection$request_sent |> req_perform() |> resp_status(), 200)

})


test_that("user information is a charater vector", {
  skip_on_cran()
  skip_if_offline()
  expect_equal(names(dhis2_play_connection$get_user_info()), c("name", "email"))

})


test_that('Resource(s) "displayName","singular","plural","href" are return', {
  skip_on_cran()
  skip_if_offline()
expect_equal(names(dhis2_play_connection$get_metadata()), c("displayName","singular","plural","href" ))

})

test_that("Type of result of a specific resouce is list", {
  skip_on_cran()
  skip_if_offline()
  expect_type(dhis2_play_connection$get_metadata(endpoint = "dataElements"), "list")

})



test_that("Type of result of possible fields is a character vector", {
  skip_on_cran()
  skip_if_offline()
  expect_type(dhis2_play_connection$get_metadata_fields(endpoint = "dataElements"), "character")

})



test_that('Wrong analytic ID returns an error', {

  skip_on_cran()
  skip_if_offline()
  expect_error(dhis2_play_connection$get_analytics(analytic = c("random_id"),
                                                   org_unit =   c("O6uvpzGd5pu", "fdc6uOvgoji"),
                                                   period = "202302",
                                                   output_scheme = "NAME"))

})




