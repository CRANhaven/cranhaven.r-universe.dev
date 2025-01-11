## this script was generated as an example of a dynamic webscrapper 
##
# %pip install selenium
# %pip install polars 


import polars as pl # # this is the authors preferred data wrangling library in python
import polars.selectors as cs ## imports selector functions like starts_with
from selenium.webdriver.common.by import By ## imports selectors
from selenium.webdriver.common.keys import Keys ## imports keystrokes 
from selenium import webdriver # imports  remote webdrivers
from selenium.webdriver.support.ui import Select ## allows you to select certain options
from selenium.webdriver.common.alert import Alert ## gracefully handles alert windows
from selenium.webdriver.support.ui import WebDriverWait ## lets you wait until element is present
from selenium.webdriver.support import expected_conditions as EC ## alllows you to handle certain kinds of errors
from selenium.common.exceptions import TimeoutException ## allows you to handle websites waiting for to long 
import time # sleep time 


## This is just the ringer fantasy football rankings 
## and is an example of website you need to click stuff with
url = 'https://fantasy.espn.com/football/players/projections'

## if you want to use chrome you may need to configure your chrome driver 
## see https://selenium-python.readthedocs.io/faq.html
driver = webdriver.Firefox()

## maximize window 
driver.maximize_window()

## navigate to url 

driver.get(url)

## we can use send keys to change what league we are in
## this is a fairly common ui when interacting with modern websites

scoring = driver.find_element(By.XPATH, '//*[@id="filterScoringType"]')

## Select a different option
scoring.send_keys('Points Non-PPR')


projections = driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/div/div/div[5]/div[2]/div[2]/div[1]/div/div[2]/div[6]/div/div[2]/select')

## you can also do 
##  projections = Select(driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/div/div/div[5]/div[2]/div[2]/div[1]/div/div[2]/div[6]/div/div[2]/select')
# lang_button.select_by_visible_text('2024 Season')

projections.send_keys('2024 Season')


## now we can get the projected rank for each player like this


get_rank = driver.find_elements(By.XPATH, '/html/body/div[1]/div[1]/div/div/div[5]/div[2]/div[3]/div/div/div/div/div/div/div/div/div/div/table/tbody/tr/td[1]') 

## here we are just using list comphresion to get everything 
## quickly
rank = [get_rank.get_attribute('textContent') for get_rank in get_rank]


get_name = driver.find_elements(By.XPATH, '/html/body/div[1]/div[1]/div/div/div[5]/div[2]/div[3]/div/div/div/div/div/div/div/div/div/div/table/tbody/tr/td[2]/div/div/div[2]/div[1]/span/a' )

name = [get_name.get_attribute('textContent') for get_name in get_name]

## to make our looper a little more readable 


def get_rank(driver):
     # here we are just telling selenium to wait until it sees everything
     wait = WebDriverWait(driver, timeout=20).until(
        EC.visibility_of_all_elements_located((By.XPATH,
        '/html/body/div[1]/div[1]/div/div/div[5]/div[2]/div[3]/div/div/div/div/div/div/div/div/div/div/table/tbody/tr/td[1]'))
    )
     ranks = [wait.get_attribute('textContent') for wait in wait]
     return ranks

def get_name(driver):
     # here we are just telling selenium to wait until it sees everything
     wait = WebDriverWait(driver, timeout=20).until(
        EC.visibility_of_all_elements_located((By.XPATH,
        '/html/body/div[1]/div[1]/div/div/div[5]/div[2]/div[3]/div/div/div/div/div/div/div/div/div/div/table/tbody/tr/td[2]/div/div/div[2]/div[1]/span/a'))
    )
     names = [wait.get_attribute('textContent') for wait in wait]
     return names


## now lets define a dictionary to add scraped data into 


data = {
    'player_names': [],
    'rank': []
}

## Since the url doesn't change we have to write a while loop 
## we can define a counter to handle how many times we click the next button since we know its ~ 22 pages
## but often times we are dealing with a lot more pages 
## and they don't let you skip to the end

next_button = driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/div/div/div[5]/div[2]/div[3]/div/div/div/div/nav/button[2]')

next_button.is_enabled()




next_button_visible = True

try:
    while next_button_visible:

        try:
            time.sleep(5) # wait for 5 seconds

            name_page = get_name(driver)
            
            rank_page = get_rank(driver)
            
            data['player_names'].append(name_page)
            
            data['rank'].append(rank_page)
           
            next_button = driver.find_element(By.XPATH, '/html/body/div[1]/div[1]/div/div/div[5]/div[2]/div[3]/div/div/div/div/nav/button[2]')
            next_button_visible = next_button.is_enabled()
            if not next_button_visible:
                print("Reached the Final Page")

                break

            next_button.click()
        except Exception as e:

            print("An error occurred:", str(e))
            break
finally:
    driver.quit()

## make into a data frame 

dat = pl.DataFrame(data)

## this is in a nested list 
## so we want to creat a nice columns

exploded = dat.explode(cs.all())

exploded.tail()

exploded.head()


## there are a variety of other popular dynamic website designs 
## one of them is scroll down for long time 

scroll_site = 'https://motherduck.com/'

driver = webdriver.Firefox()

driver.maximize_window()

driver.get(scroll_site)

## we can define some webscraping functions but basically 
## we do something like this 

while True:
    time.sleep(5)
    last_height = driver.execute_script("return document.body.scrollHeight")
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    new_height = driver.execute_script("return document.body.scrollHeight")
    if new_height == last_height:
        break
    last_height = new_height

