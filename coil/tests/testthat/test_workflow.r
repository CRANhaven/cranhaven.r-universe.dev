
test_that("A normal sequence in framed and translated properly", {

  sequence = 'ctttacctgatttttggtgcatgagcaggtatagttggaacagccctaagtctcctaattcgagctgaacttgggcaacctggatcacttttaggagatgatcagatttataatgtaatcgtaaccgcccacgcttttgtaataatctttttcatggttataccaattataattggtggtttcggaaattgattagttcctttaataattggagcgccagatatagccttcccacgaataaataacataagtttctgacttcttccaccatcatttcttcttctcctcgcctctgctggagtagaagctggagcaggtactggttgaacagtttatcctccattagctagcaatctagcacatgctggaccatctgttgatttagctattttttctcttcacttagccggtgtttcatcaattttagcttcaattaattttatcacaaccattattaatataaaaccaccagctatttcccaatatcaaacaccattatttgtttgatctattcttgtaaccactattcttcttctcctctcacttccagttcttgcagcaggaattacaatattacttacagatcgtaaccttaatactacattctttgaccctgcaggtggaggagacccaatcctttatcaacattta'
  sequence_framed = '---ctttacctgatttttggtgcatgagcaggtatagttggaacagccctaagtctcctaattcgagctgaacttgggcaacctggatcacttttaggagatgatcagatttataatgtaatcgtaaccgcccacgcttttgtaataatctttttcatggttataccaattataattggtggtttcggaaattgattagttcctttaataattggagcgccagatatagccttcccacgaataaataacataagtttctgacttcttccaccatcatttcttcttctcctcgcctctgctggagtagaagctggagcaggtactggttgaacagtttatcctccattagctagcaatctagcacatgctggaccatctgttgatttagctattttttctcttcacttagccggtgtttcatcaattttagcttcaattaattttatcacaaccattattaatataaaaccaccagctatttcccaatatcaaacaccattatttgtttgatctattcttgtaaccactattcttcttctcctctcacttccagttcttgcagcaggaattacaatattacttacagatcgtaaccttaatactacattctttgaccctgcaggtggaggagacccaatcctttatcaacattta'
  seqname = 'test_seq1'
  sequence_AAcensored = "-LYLIFGAWAG?VGTALSLLIRAELGQPGSLLGDDQIYNVIVTAHAFV?IFFMV?PI?IGGFGNWLVPL?IGAPD?AFPR?NN?SFWLLPPSFLLLLASAGVEAGAGTGWTVYPPLASNLAHAGPSVDLAIFSLHLAGVSSILASINFITTIIN??PPAISQYQTPLFVWSILVTTILLLLSLPVLAAGIT?LLTDRNLNTTFFDPAGGGDPILYQHL"
  sequence_AA5 ="-LYLIFGAWAGMVGTALSLLIRAELGQPGSLLGDDQIYNVIVTAHAFVMIFFMVMPIMIGGFGNWLVPLMIGAPDMAFPRMNNMSFWLLPPSFLLLLASAGVEAGAGTGWTVYPPLASNLAHAGPSVDLAIFSLHLAGVSSILASINFITTIINMKPPAISQYQTPLFVWSILVTTILLLLSLPVLAAGITMLLTDRNLNTTFFDPAGGGDPILYQHL"
  dat = coi5p(sequence, name = seqname)
  expect_equal(dat$raw, sequence)
  expect_equal(dat$name, seqname)

  #test the pipeline on a single instance
  data_full = coi5p_pipe(sequence, name = seqname, trans_table = 5)

  expect_equal(data_full$raw, sequence)
  expect_equal(data_full$name, seqname)
  expect_equal(data_full$framed, sequence_framed)
  expect_equal(data_full$aaSeq, sequence_AA5)
  expect_equal(data_full$indel_likely, FALSE)
  expect_equal(data_full$stop_codons, FALSE)

  #apply the pipeline to a list of coi5p sequences

  coi_output = lapply(example_barcode_data$sequence, function(x){
    coi5p_pipe(x)
  })

  out_df = flatten_coi5p(coi_output)

  out_df = flatten_coi5p(coi_output, keep_cols = c("name", "raw", "stop_codons"))

  expect_equal(out_df$stop_codons, c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE))

  expect_equal(out_df$raw, tolower(example_barcode_data$sequence))

  expect_error(flatten_coi5p(coi_output, keep_cols = "data"),
               "flatten_coi5p is not designed to return the data component of the coi5p object, it is for internal use only.")
  expect_error(flatten_coi5p(coi_output, keep_cols =c("raw", "weird_name")),
               "The coi5p objects you are flattening do not contain the column: weird_name")

  coi_output = lapply(1:length(example_barcode_data$sequence), function(i){
    coi5p_pipe(example_barcode_data$sequence[[i]], name = example_barcode_data$id[[i]])
  })

  out_df = flatten_coi5p(coi_output)

  out_df = flatten_coi5p(coi_output, keep_cols = c("name", "raw", "stop_codons"))

  expect_equal(out_df$name, example_barcode_data$id)
})

