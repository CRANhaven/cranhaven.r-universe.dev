test_that("plotCompareCW returns ggplot object", {
  data(example_data)
  label=example_data
  title="output"
  ncw<-callNCW(title=title,label=label,stability=TRUE,nperm=4,ncore=1)
  p<-plotCompareCW(title=title,label=label,ncw=ncw)
  expect_s3_class(p,"ggplot")
})
