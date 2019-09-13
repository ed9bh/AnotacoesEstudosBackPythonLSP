# %%
from time import perf_counter, sleep
from random import randint
from concurrent.futures import ThreadPoolExecutor
# %%


def do_something(x):
    print(f'Sleeping {x} second...', end='')
    sleep(x)
    return 'end well...'


# %%

start = perf_counter()

with ThreadPoolExecutor() as executer:
    r = randint(1, 9)
    f1 = executer.submit(do_something, r)
    
    print(f1.result())

finish = perf_counter()

print(f'Finishes in {round(finish - start, 2):0.2f} seconds...')
