import sys, requests

place = sys.argv[1].replace(' ', '+')
resp = requests.get(f'https://wttr.in/{place}')
print(resp.text)