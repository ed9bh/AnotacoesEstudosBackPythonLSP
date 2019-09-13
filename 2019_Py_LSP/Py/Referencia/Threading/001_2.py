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

threads = []

for _ in range(10):
    t = Thread(target=do_something)
    t.start()
    threads.append(t)
    pass

for tread in threads:
    tread.join()
    pass

finish = perf_counter()

print(f'Finishes in {round(finish - start, 2):0.2f} seconds...')
