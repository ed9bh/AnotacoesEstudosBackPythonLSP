# %%
from matplotlib import pyplot as plt
import numpy as np
import csv
from collections import Counter
import pandas as pd

# %%
# Dados

ages_x = [i for i in range(25, 36)]

x_indexes = np.arange(len(ages_x))
width = 0.25

dev_y = [
    38_496,
    42_000,
    46_752,
    49_320,
    53_200,
    56_000,
    62_316,
    64_928,
    67_317,
    68_748,
    73_752,
]

py_dev_y = [
    45_372,
    48_876,
    53_850,
    57_287,
    63_016,
    65_998,
    70_003,
    70_000,
    71_496,
    75_370,
    83_640,
]

js_dev_y = [
    37_810,
    43_515,
    46_829,
    49_293,
    53_437,
    56_373,
    62_375,
    66_674,
    68_745,
    68_746,
    74_583,
]
#%%
# Style
# plt.style.available
# plt.style.use('grayscale')
# plt.xkcd()

# Data
plt.plot(ages_x, dev_y, color="red", linestyle="--", marker="o", label="All Devs")
plt.plot(ages_x, js_dev_y, color="#adad3b", linewidth=3, label="Js Devs")
plt.plot(ages_x, py_dev_y, color="cyan", linestyle="-.", label="Py Devs")

# Formating
plt.title("Median Dev Salary (USD) by Age")
plt.xlabel("Age")
plt.ylabel("Salary")
# plt.legend(['All Devs', 'Py Devs'])
plt.legend()
plt.grid(True)
# plt.tight_layout()
plt.show()

# %%

plt.style.use("fivethirtyeight")

plt.bar(x_indexes - width, dev_y, width=width, label="All Devs")
plt.bar(x_indexes, js_dev_y, width=width, label="Js Devs")
plt.bar(x_indexes + width, py_dev_y, width=width, label="Py Devs")

# Formating
plt.title("Median Dev Salary (USD) by Age")
plt.xlabel("Age")
plt.ylabel("Salary")
plt.legend()
plt.xticks(ticks=x_indexes, labels=ages_x)
plt.show()

#%%

plt.style.use("fivethirtyeight")

with open("data.csv") as csv_file:
    csv_reader = csv.DictReader(csv_file)

    laguage_counter = Counter()

    for row in csv_reader:
        laguage_counter.update(row["LanguagesWorkedWith"].split(";"))

languages = []
popularity = []

for item in laguage_counter.most_common(15):
    languages.append(item[0])
    popularity.append(item[1])

#%%

plt.bar(languages, popularity)

plt.title("Most popular Languages")
plt.xlabel("Programing Languages")
plt.ylabel("Number of People Who Use")

plt.tight_layout()

#%%

languages.reverse()
popularity.reverse()

plt.barh(languages, popularity)

plt.title("Most popular Languages")
# plt.ylabel('Programing Languages')
plt.xlabel("Number of People Who Use")

plt.tight_layout()

#%%
data = pd.read_csv("data.csv")
ids = data["Responder_id"]
lang = data["LanguagesWorkedWith"]

laguage_counter = Counter()

for resp in lang:
    laguage_counter.update(resp.split(";"))

languages = []
popularity = []

for item in laguage_counter.most_common(20):
    languages.append(item[0])
    popularity.append(item[1])

languages.reverse()
popularity.reverse()

plt.barh(languages, popularity)

plt.title("Most popular Languages")
# plt.ylabel('Programing Languages')
plt.xlabel("Number of People Who Use")

plt.tight_layout()

#%%
# Pie Charts
# plt.style.available
# plt.style.use("fivethirtyeight")
plt.style.use("classic")
# plt.style.use("dark_background")
# plt.style.use('grayscale')
# plt.xkcd(False)

slices = [65, 42, 27, 36, 81]
label = ["AAA", "BBB", "CCC", "DDD", "EEE"]
colors = ["cyan", "red", "purple", "green", "yellow"]
expl = [0, 0, 0.1, 0, 0]

plt.pie(
    slices,
    labels=label,
    explode=expl,
    shadow=True,
    startangle=180,
    autopct="%1.1f%%",
    wedgeprops={"edgecolor": "black"},
    colors=colors,
)

plt.title("My Pie Chart")
plt.tight_layout()
plt.show()

#%%

# StackPlots

plt.style.use("fivethirtyeight")
# plt.style.use("classic")

minutes = [i for i in range(1, 10)]

player1 = [1, 2, 3, 3, 4, 4, 4, 4, 5]
player2 = [1, 1, 1, 1, 2, 2, 2, 3, 4]
player3 = [1, 1, 1, 2, 2, 2, 3, 3, 3]

labels = ["player1", "player2", "player3"]
colors = ["#6d904f", "#fc4f30", "#008fd5"]

plt.stackplot(minutes, player1, player2, player3, labels=labels, colors=colors)

plt.legend(loc="upper left")

plt.title("My Stack Plot")
plt.tight_layout()
plt.show()

#%%

# StackPlots

plt.style.use("fivethirtyeight")

minutes = [i for i in range(10, 19)]

player1 = [8, 6, 5, 5, 4, 2, 1, 1, 0]
player2 = [0, 1, 2, 2, 2, 4, 4, 4, 4]
player3 = [0, 1, 1, 1, 2, 2, 3, 3, 4]

labels = ["player1", "player2", "player3"]
colors = ["#6d904f", "#fc4f30", "#008fd5"]

plt.stackplot(minutes, player1, player2, player3, labels=labels, colors=colors)

plt.legend(loc=(0.01, 0.01))

plt.title("My Stack Plot")
plt.tight_layout()
plt.show()

#%%
