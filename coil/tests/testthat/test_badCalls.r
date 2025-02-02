
test_that("Bad function calls return the proper warnings.", {

  sequence = 'ctttacctgatttttggtgcatgagcaggtatagttggaacagccctaagtctcctaattcgagctgaacttgggcaacctggatcacttttaggagatgatcagatttataatgtaatcgtaaccgcccacgcttttgtaataatctttttcatggttataccaattataattggtggtttcggaaattgattagttcctttaataattggagcgccagatatagccttcccacgaataaataacataagtttctgacttcttccaccatcatttcttcttctcctcgcctctgctggagtagaagctggagcaggtactggttgaacagtttatcctccattagctagcaatctagcacatgctggaccatctgttgatttagctattttttctcttcacttagccggtgtttcatcaattttagcttcaattaattttatcacaaccattattaatataaaaccaccagctatttcccaatatcaaacaccattatttgtttgatctattcttgtaaccactattcttcttctcctctcacttccagttcttgcagcaggaattacaatattacttacagatcgtaaccttaatactacattctttgaccctgcaggtggaggagacccaatcctttatcaacattta'

  expect_error(coi5p(), "Must pass a DNA sequence.")

  expect_error(coi5p("ATGCATFA"), "Unallowed character in DNA string: f \nValid characters are: a t g c - n")

  dat = coi5p(sequence)

  expect_error(translate(dat), "translate function only accepts framed coi5p objects. See function: frame.")

  expect_error(indel_check(dat),"indel_check function only accepts framed and translated coi5p objects. See functions: frame, translate.")

})

