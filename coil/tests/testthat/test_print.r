test_that("coi5p objects are printed properly", {

  #baseline obj
  seqname = "test_seq1"
  sequence = 'ctttacctgatttttggtgcatgagcaggtatagttggaacagccctaagtctcctaattcgagctgaacttgggcaacctggatcacttttaggagatgatcagatttataatgtaatcgtaaccgcccacgcttttgtaataatctttttcatggttataccaattataattggtggtttcggaaattgattagttcctttaataattggagcgccagatatagccttcccacgaataaataacataagtttctgacttcttccaccatcatttcttcttctcctcgcctctgctggagtagaagctggagcaggtactggttgaacagtttatcctccattagctagcaatctagcacatgctggaccatctgttgatttagctattttttctcttcacttagccggtgtttcatcaattttagcttcaattaattttatcacaaccattattaatataaaaccaccagctatttcccaatatcaaacaccattatttgtttgatctattcttgtaaccactattcttcttctcctctcacttccagttcttgcagcaggaattacaatattacttacagatcgtaaccttaatactacattctttgaccctgcaggtggaggagacccaatcctttatcaacattta'
  #sequence 2 contians indel errors
  sequence2 = 'ctttatttaatttttggtgcatgagcaggaatagttggaacggctttaagtcttctaatccgagctgaactaggaccaacctgggtctctcctagggggatgatcaaatttataatgtaattgtaaccgcccatgcttttgtaataattttctttatagtaatacctgtcataattggtggttttggaaattaactaattccattaataattggtgcacctgacatagccttcccacgaataaataacataagctcctgacttcttccaccatcatttctccttctcctcgcctccgctggggttgaagccggagcaggtaccggttgaacagtttaccccccactggcaagcaaccttgctcatgccggaccatctgttgatttagctatcttctccctccatttagctggtatttcatcaattttagcctcaatccaacttcatcacaactattattaatataaaacccccagccatttctcaatatcaaacaccactatttgtttgatctatccttgtaactactattcttctcctcctttccctcccagttcttgcagcaggaattacaatcttacttacagaccgcaaccttaatactacattctttgatcctgcaggtggaggagacccaatcctttaccaacaccta'

  #######
  # print test 1
  #######
  dat = coi5p(sequence)

  expected1 = "coi5p barcode sequence
raw sequence:
ctttacctgatttttggtgcatgag...agacccaatcctttatcaacattta"

  dstr1 = capture_output(dat, print=TRUE)

  expect_equal(dstr1, expected1)

  #######
  # print test 2
  #######
  # a coi5p object with a name

  dat = coi5p_pipe(sequence, name = seqname)

  expected2 = "coi5p barcode sequence: test_seq1
raw sequence:
ctttacctgatttttggtgcatgag...agacccaatcctttatcaacattta
framed sequence:
---ctttacctgatttttggtgcat...agacccaatcctttatcaacattta
Amino acid sequence:
-LYLIFGAWAG?VGTALSLLIRAEL...LTDRNLNTTFFDPAGGGDPILYQHL
Raw sequence was trimmed: FALSE
Stop codon present: FALSE, Amino acid PHMM score:-197.41253
The sequence likely does not contain an insertion or deletion.
Base pair 1 of the raw sequence is base pair 4 of the COI-5P region."

  dstr2 = capture_output(dat, print=TRUE)

  expect_equal(dstr2, expected2)

  #######
  # print test 3
  #######
  #test object print after each stage
  dat = coi5p(sequence, name = seqname)

  expected3 = "coi5p barcode sequence: test_seq1
raw sequence:
ctttacctgatttttggtgcatgag...agacccaatcctttatcaacattta"

  dstr3 = capture_output(dat, print=TRUE)

  expect_equal(dstr3, expected3)

  #######
  # print test 4
  #######

  dat = frame(dat)
  expected4 = "coi5p barcode sequence: test_seq1
raw sequence:
ctttacctgatttttggtgcatgag...agacccaatcctttatcaacattta
framed sequence:
---ctttacctgatttttggtgcat...agacccaatcctttatcaacattta
Raw sequence was trimmed: FALSE
Base pair 1 of the raw sequence is base pair 4 of the COI-5P region."

  dstr4 = capture_output(dat, print=TRUE)

  expect_equal(dstr4, expected4)

  #######
  # print test 5
  #######

  dat = translate(dat)

  expected5 = "coi5p barcode sequence: test_seq1
raw sequence:
ctttacctgatttttggtgcatgag...agacccaatcctttatcaacattta
framed sequence:
---ctttacctgatttttggtgcat...agacccaatcctttatcaacattta
Amino acid sequence:
-LYLIFGAWAG?VGTALSLLIRAEL...LTDRNLNTTFFDPAGGGDPILYQHL
Raw sequence was trimmed: FALSE
Base pair 1 of the raw sequence is base pair 4 of the COI-5P region."

  dstr5 = capture_output(dat, print=TRUE)

  expect_equal(dstr5, expected5)

  #######
  # print test 6
  #######

  dat = indel_check(dat)

  expected6 = "coi5p barcode sequence: test_seq1
raw sequence:
ctttacctgatttttggtgcatgag...agacccaatcctttatcaacattta
framed sequence:
---ctttacctgatttttggtgcat...agacccaatcctttatcaacattta
Amino acid sequence:
-LYLIFGAWAG?VGTALSLLIRAEL...LTDRNLNTTFFDPAGGGDPILYQHL
Raw sequence was trimmed: FALSE
Stop codon present: FALSE, Amino acid PHMM score:-197.41253
The sequence likely does not contain an insertion or deletion.
Base pair 1 of the raw sequence is base pair 4 of the COI-5P region."

  dstr6 = capture_output(dat, print=TRUE)

  expect_equal(dstr6, expected6)

  #######
  # print test 7
  #######
  #test a sequence with errors prints properly

  dat = coi5p_pipe(sequence2)

  expected7 = "coi5p barcode sequence
raw sequence:
ctttatttaatttttggtgcatgag...agacccaatcctttaccaacaccta
framed sequence:
---ctttatttaatttttggtgcat...agacccaatcctttaccaacaccta
Amino acid sequence:
-LYLIFGAWAG?VGTALSLLIRAEL...LTDRNLNTTFFDPAGGGDPILYQHL
Raw sequence was trimmed: FALSE
Stop codon present: TRUE, Amino acid PHMM score:-757.47993
The sequence likely contains an insertion or deletion.
Base pair 1 of the raw sequence is base pair 4 of the COI-5P region."

  dstr7 = capture_output(dat, print=TRUE)

  expect_equal(dstr7, expected7)

})
