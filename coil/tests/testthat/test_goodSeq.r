
test_that("A normal sequence in framed and translated properly", {

  sequence = 'ctttacctgatttttggtgcatgagcaggtatagttggaacagccctaagtctcctaattcgagctgaacttgggcaacctggatcacttttaggagatgatcagatttataatgtaatcgtaaccgcccacgcttttgtaataatctttttcatggttataccaattataattggtggtttcggaaattgattagttcctttaataattggagcgccagatatagccttcccacgaataaataacataagtttctgacttcttccaccatcatttcttcttctcctcgcctctgctggagtagaagctggagcaggtactggttgaacagtttatcctccattagctagcaatctagcacatgctggaccatctgttgatttagctattttttctcttcacttagccggtgtttcatcaattttagcttcaattaattttatcacaaccattattaatataaaaccaccagctatttcccaatatcaaacaccattatttgtttgatctattcttgtaaccactattcttcttctcctctcacttccagttcttgcagcaggaattacaatattacttacagatcgtaaccttaatactacattctttgaccctgcaggtggaggagacccaatcctttatcaacattta'
  sequence_framed = '---ctttacctgatttttggtgcatgagcaggtatagttggaacagccctaagtctcctaattcgagctgaacttgggcaacctggatcacttttaggagatgatcagatttataatgtaatcgtaaccgcccacgcttttgtaataatctttttcatggttataccaattataattggtggtttcggaaattgattagttcctttaataattggagcgccagatatagccttcccacgaataaataacataagtttctgacttcttccaccatcatttcttcttctcctcgcctctgctggagtagaagctggagcaggtactggttgaacagtttatcctccattagctagcaatctagcacatgctggaccatctgttgatttagctattttttctcttcacttagccggtgtttcatcaattttagcttcaattaattttatcacaaccattattaatataaaaccaccagctatttcccaatatcaaacaccattatttgtttgatctattcttgtaaccactattcttcttctcctctcacttccagttcttgcagcaggaattacaatattacttacagatcgtaaccttaatactacattctttgaccctgcaggtggaggagacccaatcctttatcaacattta'
  seqname = 'test_seq1'
  sequence_AAcensored = "-LYLIFGAWAG?VGTALSLLIRAELGQPGSLLGDDQIYNVIVTAHAFV?IFFMV?PI?IGGFGNWLVPL?IGAPD?AFPR?NN?SFWLLPPSFLLLLASAGVEAGAGTGWTVYPPLASNLAHAGPSVDLAIFSLHLAGVSSILASINFITTIIN??PPAISQYQTPLFVWSILVTTILLLLSLPVLAAGIT?LLTDRNLNTTFFDPAGGGDPILYQHL"
  sequence_AA5 ="-LYLIFGAWAGMVGTALSLLIRAELGQPGSLLGDDQIYNVIVTAHAFVMIFFMVMPIMIGGFGNWLVPLMIGAPDMAFPRMNNMSFWLLPPSFLLLLASAGVEAGAGTGWTVYPPLASNLAHAGPSVDLAIFSLHLAGVSSILASINFITTIINMKPPAISQYQTPLFVWSILVTTILLLLSLPVLAAGITMLLTDRNLNTTFFDPAGGGDPILYQHL"
  dat = coi5p(sequence, name = seqname)
  expect_equal(dat$raw, sequence)
  expect_equal(dat$name, seqname)


  dat = frame(dat)
  expect_equal(dat$framed, sequence_framed)

  dat = translate(dat)
  expect_equal(dat$aaSeq, sequence_AAcensored)

  dat = translate(dat, trans_table = 5)
  expect_equal(dat$aaSeq, sequence_AA5)

  dat = indel_check(dat)
  expect_equal(dat$indel_likely, FALSE)
  expect_equal(dat$stop_codons, FALSE)


  #here is some additional sequences to test, it has a single outlier match prior to 4 deletes, then a string of matches
  #need to change the frame logic so that this type of sequence is framed properly - back port the debar logic and see
  #if performance is improved

  seq_outlie = "TATGCTTTATTTTATTTTTGCTACCTGATCTGGAATGGTGGCTACAGGTTTAAGAGTTCTAATTCGAATTGAGCTAAGCGTTGCTACAGGCTGAATAGGAGACGATCAGCTTTACAACGTAATTGTTACGGCTCACGCTTTAATTATGTTATTTTTCTTTCTAATGCCTTTCCTTATGGGAGGATTTGGTAATACTCTTGTTCCTCTTATGATTGGAGCTCCAGACATGGCGTTCCCTCGAATGAACAACATGAGATTCTGAATGCTTCCCCCTTCTATGACACTTCTTCTAACATCTGCCCTAATTGAAAGAGGGGCAGGTACAGGATGGACTGTTTACCCTCCGCTATCAGGGATTGTATCCCATGCTGGTGGAAGGGTAGACTTGGCGATTTTTTCGTTACACCTTTCCGGTGCGTCTTCAATTTTAGGTACTGTAAATTTTCTTGCCACAGTGTTTAATATGCGAGGGCCTGGAATCACTTTCGAGCGAACCCCTCTATTTGTATGAGCTATGGTAGTTACAGTTGTTCTGTTACTTTTATCCCTTCCGGTATTTGCTGGTGGGATTACTATGCTACTTACAGATCGAAACTTCAATACTAGATTTTTCGATCCTGCTGGGGGTGGTGATCCTATTTTATTCCAGCACTTATTT"
  dat = coi5p(seq_outlie)
  dat = frame(dat)
  processed_outlie = coi5p_pipe(seq_outlie)

  #processed_outlie$indel_likely == FALSE
  expect_equal(processed_outlie$indel_likely, FALSE)
  #processed_outlie$stop_codons == FALSE
  expect_equal(processed_outlie$stop_codons, FALSE)


  #additional example - a sequence that was misframed on previous version, due to being slightly too long, but that has a good COI
  #region
  seq_left_add = "AATTTTATATTTTATTTTAGGTATATGATCAGGAATAATTGGTGCATCTATAAGTATTATTATTCGATTAGAATTAGGTAATCCTGGTTATTTAATTAATAATGATCAAATTTATAATTCTATTGTTACAGCCCATGCTTTCATTATAATTTTTTTTATAGTAATACCCATTATAATTGGAGGATTTGGTAATTGATTAATCCCATTAATACTTGGAGCTCCAGATATAGCATTTCCTCGAATAAATAATATAAGTTTTTGACTATTACCACCTTCACTATTATTATTATTAAATAGAAGATTAATTAATCAAGGTGTAGGAACCGGATGAACAGTTTATCCTCCTTTATCTTTAAATATTAATCATGAAGGTATATCAATTGATATAGCAATTTTTTCACTCCATCTTGCTGGTATATCATCAATTATAGGAGCAATTAATTTTATTACTACCATTATAAATATATTTCCATTAAAATTAAAATTTGAACAATTAACTTTATTTACATGATCAATTTTAATTACTACAATTTTATTATTAATTGCAGTACCTGTTTTAGCAGGAGCAATTACCATATTATTAACTGATCGAAATTTAAATACTTCATTTTTTGACCCATCCGGGGGAGGAGATCCAATTTTATATCAACATTTATTT"

  dat = coi5p(seq_left_add)
  dat = frame(dat)

  #here is the long form code of the triple translate
  d0 = translate(dat)
  d0 = indel_check(d0)
  d1 = translate(dat, frame_offset = 1)
  d1 = indel_check(d1)
  d2 = translate(dat, frame_offset = 2)
  d2 = indel_check(d2)

  scores = c(d0$aaScore,
              d1$aaScore,
              d2$aaScore)
  best_frame = which.max(scores)
  coi_objs = list(d0, d1, d2)
  out = coi_objs[[best_frame]]

  processed_left_add = coi5p_pipe(seq_left_add, triple_translate = TRUE)
  #processed_left_add$stop_codons == FALSE
  expect_equal(processed_left_add$stop_codons, FALSE)

})

