#%%
from requests import get
import re
#%%

def make_list(channel_link:str)->list:
    page = get(channel_link).content
    links_raw = re.findall('watch\?v=[a-zA-Z0-9-_]{5,20}', str(page))
    link_list = []

    for c, l in enumerate(links_raw):
        link_list.append(f'https://www.youtube.com/{l}')
        pass

    return link_list

#%%

#### Area de Teste

if __name__ == '__main__':
    channel_link_test = 'https://www.youtube.com/c/Advers%C3%A1riodoEstado'

    link_list = make_list(channel_link=channel_link_test)

    for i in link_list:
        print(i)