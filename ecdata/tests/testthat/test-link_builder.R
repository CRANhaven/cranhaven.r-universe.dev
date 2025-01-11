test_that('checking the link building function',
{

## we want to test to see what happens when we feed the linkbuilder 
## a bad link 
  
  
objs = link_builder(country = 'United States of America', ecd_version = '1.0.0')
  
expect_equal(objs, 'https://github.com/Executive-Communications-Dataset/ecdata/releases/download/1.0.0/united_states_of_america.parquet')
  
  
obs_two = link_builder(country = c('Argentina', 'Turkey', 'Czechia'), ecd_version = '1.0.0')
  
link_vec = c('https://github.com/Executive-Communications-Dataset/ecdata/releases/download/1.0.0/argentina.parquet',
             'https://github.com/Executive-Communications-Dataset/ecdata/releases/download/1.0.0/czechia.parquet',
            'https://github.com/Executive-Communications-Dataset/ecdata/releases/download/1.0.0/turkey.parquet')
  
expect_equal(obs_two, link_vec)  


})
