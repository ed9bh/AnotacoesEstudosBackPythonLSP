# %%
from time import perf_counter, sleep
from random import randint
from multiprocessing import Process

# %%


def do_something(x):
    print(f'Sleeping {x} second(s)...')
    sleep(x)
    print('Done sleeping...')
    pass


# %%
if __name__ == '__main__':
    start = perf_counter()
    processess = []
    for _ in range(10):
        seconds = randint(1, 3)
        p = Process(target=do_something, args=[seconds])
        p.start()
        processess.append(p)

    for process in processess:
        p.join()

    finish = perf_counter()

    print(f'Finish in {finish - start:0.2f} second(s)...')
