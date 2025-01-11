test_that("Testing whether load_ecd fails nicely",


  {
     expect_error(

      load_ecd()

     )

    expect_error(
      load_ecd(country = 2.0)
    )

    expect_error(load_ecd(ecd_version = '1.2.0'))

}



)