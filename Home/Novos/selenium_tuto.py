# pip install --upgrade selenium
# pip install --upgrade chromedriver-binary

# %%
from selenium import webdriver
#from selenium.webdriver.common.by import By
import chromedriver_binary

# %%
driver = webdriver.Chrome(executable_path=chromedriver_binary.chromedriver_filename)

# %%
try:
    driver.get('http://www.instagram.com/pycodebr/')
    input()
except Exception as err:
    print(err)