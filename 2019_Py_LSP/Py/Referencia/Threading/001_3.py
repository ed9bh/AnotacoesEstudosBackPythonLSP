# %%
from time import perf_counter, sleep
from random import randint
from threading import Thread
# %%


def do_something(x):
    print(f'Sleeping {x} second...', end='')
    sleep(x)
    print('end well...')
    pass


# %%

start = perf_counter()

threads = []

for _ in range(10):
    r = randint(1, 9)
    t = Thread(target=do_something, args=[r])
    t.start()
    threads.append(t)
    pass

for tread in threads:
    tread.join()
    pass

finish = perf_counter()

print(f'Finishes in {round(finish - start, 2):0.2f} seconds...')
