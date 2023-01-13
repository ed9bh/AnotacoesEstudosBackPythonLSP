from bs4 import BeautifulSoup
from requests import get as WB
from tkinter import Tk
from os import system
from secrets import token_hex
from time import sleep

system('cls')

rt = Tk()
link = rt.clipboard_get()
html = WB(link).content
soup = BeautifulSoup(html, 'html.parser')
#soup.prettify()
text = soup.get_text()
name_file = token_hex(18)
name_file = f'{name_file}.txt'

with open(name_file, mode='w+', encoding='utf-8') as target:
    target.write(text)
    pass

sleep(3)
system('pause')