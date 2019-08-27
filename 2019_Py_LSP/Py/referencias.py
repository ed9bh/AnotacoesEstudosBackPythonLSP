# %%
import asyncio
print("\32aaaaa")

# %%
a = [i ** (1 / 17) for i in range(1, 100)]
a
# %%


def fib(num):
    a, b = 0, 1
    for i in range(0, num):
        yield "{} : {}".format(i + 1, a)
        a, b = b, a + b


# %%
for item in fib(99):
    print(item)

# %%
cond = True
x = 1 if cond else 0
x

# %%
n = 10_000_000_000.33
print(n)
print(f"{n:,}")

# %%
for index, name in enumerate(["Eric", "Drumond", "Gomes"], start=9):
    print(index, name)

# %%
names = ["Kal El", "Kara Zor El", "Diana Prince", "Bruce Wayne"]
heroes = ["Superman", "Power Woman", "Wonder Woman", "Batman"]
origem = ["Krypton", "Krypton", "Themyscira", "Gotham"]

for name, hero, place in zip(names, heroes, origem):
    print(f"{hero} is {name} from {place}")

# %%
a, b, *c, d = (1, 2, 3, 4, 5, 6)
print(a)
print(b)
print(c)
print(d)

# %%


class Person:
    pass


person = Person()

fk = "First"
fv = "Eric"

setattr(person, fk, fv)

first = getattr(person, fk)

print(first)
# %%
person2 = Person()
p_info = {"first": "Eric", "last": "Drumond"}

for k, v in p_info.items():
    setattr(person2, k, v)

for k in p_info.keys():
    print(getattr(person2, k))

# %%
# Não está funcionando no IPython do VSCode (Python Interactive) !!!
# https://www.youtube.com/watch?v=L3RyxVOLjz8


async def test():
    await asyncio.sleep(5)
    print("Teste...1, 2, 3")
    await asyncio.sleep(15)
    print("Done...")


def main():
    loop = asyncio.get_event_loop()
    loop.run_until_complete(test())
    loop.close()


try:
    main()
    pass
except Exception as error:
    print(error)

# %%
a = [1, 2, 3]
b = a[:]
b.append(4)
print(a)
print(b)

# %%
a = {'a': 1, 'b': 2, 'c': 3}
b = a.copy()
b['d'] = 4
print(a)
print(b)
# %%

265 - 78.5009

#%%
