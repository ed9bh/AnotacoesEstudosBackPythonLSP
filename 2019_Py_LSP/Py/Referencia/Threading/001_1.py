# %%
from time import perf_counter, sleep
from random import randint
from threading import Thread
# %%


def do_something():
    r = randint(1, 9)
    print(f'Sleeping {r} second...', end='')
    sleep(r)
    print('end well...')
    pass


# %%
start = perf_counter()

t1 = Thread(target=do_something)
t2 = Thread(target=do_something)

t1.start()
t2.start()

t1.join()
t2.join()

finish = perf_counter()

print(f'Finishes in {round(finish - start, 2):0.2f} seconds...')
