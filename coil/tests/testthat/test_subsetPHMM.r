test_that("PHMMs can be subset as expected", {
	expect_error(subsetPHMM(nt_coi_PHMM, 3, 1222), "Index error, end position out of bounds. Input PHMM only has a length of: 657")
	expect_error(subsetPHMM(nt_coi_PHMM, 7, 2), "Index error, end position must match or exceed the start position.")

	# Subsetting a PHMM
	# builda subsection of nt_coi_PHMM that should be 60 profile positions in length
	nt_start = 333
	nt_end = 392

	nt_333PHMM = subsetPHMM(nt_coi_PHMM, nt_start , nt_end)
	expect_equal(nt_333PHMM$size, 60)

	expect_equal(all.equal(nt_333PHMM$E[,1], nt_coi_PHMM$E[,333]), TRUE)
	expect_equal(all.equal(nt_333PHMM$A[,ncol(nt_333PHMM$A)], nt_coi_PHMM$A[,392]), TRUE)

	#subset the aa_coi_PHMM in the same manner
	aa_start = nt_start/3
	aa_end = aa_start + (nt_333PHMM$size/3) -1

	aa_333PHMM = subsetPHMM(aa_coi_PHMM, aa_start , aa_end)
	expect_equal(aa_333PHMM$size, 20)

	#example subset, starting at the specified position, 333 in folmer region
  start_333 = 'tgtatatcctcctttagcaggtaatttagcacatgctggcccctctgttgatttagcca'
	start_333_error = 'tgtatatcctcctttagccaggtaatttagcacatgctggcccctctgttgatttagcca'


})
