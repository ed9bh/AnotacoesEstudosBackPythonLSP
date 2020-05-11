# %%
### https://www.youtube.com/watch?v=Lbfe3-v7yE0
# %%
import socket
# %%
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((socket.gethostname(), 1234))
s.listen(5)
# %%
while True:
    clientsocket, address = s.accept()
    print(address)
    print(f'Connection from {address} has been established!')
    clientsocket.send(bytes('Welcome to the Server!!!', 'utf-8'))
    clientsocket.close()