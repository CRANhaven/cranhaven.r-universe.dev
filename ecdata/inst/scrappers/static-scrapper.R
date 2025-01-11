# This is the example script triggered by
# example_scrapper()
# To make your scrapper we are going to load rvest

library(rvest)


# we have an example url that we are going to scrape
# but you should insert yours! 

url <- 'https://books.toscrape.com/'

## Lets check to make sure we can scrape the webpage
polite::bow(url)

## The part you care about is the crawl delay and whether it is scrapable
## We can scrape this website but we should wait for 5 seconds


## if we navigate to the site in your web browser and click
## next page the link changes! 
## we can reconstruct every link we need
## this is broadly the same process

links_data <-  paste0('https://books.toscrape.com/catalogue/page-',
  seq(1, 50, 1), '.html')

## Now lets say we want to get all the links on these pages 
## you are going to right click on the thing you want to scrape 
## and then click inspect

links_from_webpage <-  read_html(links_data[1]) |> 
  # the #default is the id tag 
  # .image_container is the class we are targetting
  # a is just the html way of declaring a hyperlink
  html_elements('#default .image_container a') |> 
  html_attr('href') 

## ok this grabs all the links we wanted 
## but these are not valid links 

links_from_webpage[1]

## we can fix these like this
fixed_links <- paste0('https://books.toscrape.com/catalogue/', links_from_webpage)



descript = read_html(fixed_links[1]) |> 
  html_elements('#content_inner > article > p') |> 
  html_text()




## if you want to iterate this over a whole bunch of things we 
## can write a function 
## I prefer this approach to using map inside a dataframe! 

scrapper = \(links){

text = read_html(links) |> 
  html_elements('#content_inner > article > p') |> 
  html_text() 


## lets just grab the title of the book
## we sometimes need to use something called an xpath
## we can do this by just adding the xpath argument
title  = read_html(links) |> 
  html_elements(xpath = '//*[@id="content_inner"]/article/div[1]/div[2]/h1') |> 
  html_text()
  
## Now lets grab the "date" or in this case the price 
  
date = read_html(links) |> 
  html_elements('#content_inner .price_color') |> 
  html_text()


text_data = data.frame(text = text,
                       title = title,
                       date = date,
                       url = links)
  
## If you remember earlier it says wait for 5 seconds 
## It can be helpful for you to add a random sleep to disguise your 
## scrapper

Sys.sleep(sample(5:8, size = 1))
  
## I like a false sense of progress
  
cat("Done Scraping:", links, sep = '\n')
  
  
## we need to actually return a data set
  
return(text_data)

}

## now we need to iterate it 
## I prefer map or lapply to a for loop

examp_vec = fixed_links[1:5]

## we may also want to bake in some try functionality
## for me I think possibly is the simpelest albeit a little inflexible 

pos_scrapper = purrr::possibly(scrapper)

# examp = map(examp_vec, \(x) scrapper(x))
scraped_dat = lapply(examp_vec, \(x) pos_scrapper(x))

## now we can go and bing this together 
## there are a lot of ways to do this 
## I kind of prefer list_rbind
## but to avoid loading in the tidyverse for you
## we are just going to use base r 
## the equivalent would be 
## text_dat = list_rbind(examp)

text_dat = do.call("rbind", scraped_dat)

## now do catch cases that didn't work we can do something like this 

rescrape = which(lengths(scraped_dat) == 0)

## Then we can add use the lengths of our vector to our advantage to find links that 
## were not scrapped and then check that everything still works 

