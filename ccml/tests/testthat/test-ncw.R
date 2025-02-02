test_that("check callNCW output dim", {
  data(example_data)
  label=example_data
  title="output"
  ncw<-callNCW(title=title,label=label,stability=TRUE,nperm=4,ncore=1)
  expect_equal(nrow(ncw),10)
  expect_equal(ncol(ncw),10)
})
