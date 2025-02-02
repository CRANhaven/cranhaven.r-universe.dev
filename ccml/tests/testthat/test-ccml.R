test_that("ccml returns list", {
  # expect_equal(2 * 2, 4)
  data(example_data)
  label=example_data
  title="output"
  res_1=ccml(title=title,label=label,nperm = 3,ncore=1,stability=FALSE,maxK=3,pItem=0.8)
  expect_type(res_1,"list")



  res_2<-ccml(title=title,label=label,nperm = 10,ncore=1,stability=FALSE,maxK=3,
              pItem=0.9,clusterAlg = "hc")
  expect_type(res_2,"list")



  res_3<-ccml(title=title,label=label,output=FALSE,nperm = 5,ncore=1,stability=TRUE,maxK=3,
              pItem=0.9)
  expect_type(res_3,"list")
})


test_that("check ccml output length", {
  # expect_equal(2 * 2, 4)
  data(example_data)
  label=example_data
  title="output"
  res_1=ccml(title=title,label=label,nperm = 3,ncore=1,stability=FALSE,maxK=3,pItem=0.8)
  expect_equal(length(res_1),3)

  res_2=ccml(title=title,label=label,nperm = 10,ncore=1,stability=FALSE,maxK=3,
             pItem=0.9,clusterAlg = "hc")
  expect_equal(length(res_2),3)


  res_3=ccml(title=title,label=label,output=FALSE,nperm = 5,ncore=1,stability=TRUE,maxK=3,
             pItem=0.9)
  expect_equal(length(res_3),3)

})
