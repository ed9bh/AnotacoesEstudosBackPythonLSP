# %%
from time import perf_counter, sleep
from random import randint
from concurrent.futures import ProcessPoolExecutor, as_completed
# %%


def do_something(x):
    print(f'Sleeping {x} second(s)...')
    sleep(x)
    return f'Done sleeping...{x}'


# %%
if __name__ == '__main__':
    start = perf_counter()

    with ProcessPoolExecutor() as executer:
        seconds = []
        for _ in range(10):
            s = randint(1, 5)
            seconds.append(s)

        results = executer.map(do_something, seconds)

        for result in results:
            print(result)

    finish = perf_counter()

    print(f'Finish in {finish - start:0.2f} second(s)...')
