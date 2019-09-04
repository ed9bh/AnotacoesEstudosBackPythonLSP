# %%
from os import chdir

chdir(r"A:\_DevCadLspPy\Dev\Referencias")

from matplotlib import pyplot as plt
from matplotlib import dates as mpl_dates
from matplotlib.animation import FuncAnimation
from datetime import datetime, timedelta
from collections import Counter
from itertools import count
import numpy as np
import csv
import pandas as pd
import random
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
data = pd.read_csv(r"data2.csv")
ages = data["Age"]
dev_salaries = data["All_Devs"]
py_salaries = data["Python"]
js_salaries = data["JavaScript"]

plt.plot(ages, dev_salaries, color="#444444", linestyle="--", label="All Devs")

plt.plot(ages, py_salaries, label="Python")

# plt.plot(ages, js_salaries, label="JavaScript")

overall_median = 57287

# plt.fill_between(ages, py_salaries, overall_median, alpha=0.125)

# plt.fill_between(ages, py_salaries, overall_median,
# where=(py_salaries > overall_median), interpolate=True, color='blue',
# alpha=0.125)

# plt.fill_between(ages, py_salaries, overall_median,
# where=(py_salaries <= overall_median), interpolate=True, color='red',
# alpha=0.125)

plt.fill_between(
    ages,
    py_salaries,
    dev_salaries,
    where=(py_salaries > dev_salaries),
    interpolate=True,
    color="blue",
    alpha=0.25,
    label="Above Avg",
)

plt.fill_between(
    ages,
    py_salaries,
    dev_salaries,
    where=(py_salaries <= dev_salaries),
    interpolate=True,
    color="red",
    alpha=0.25,
    label="Below Avg",
)

plt.legend()

plt.title("Median Salary by Age")
plt.xlabel("Ages")
plt.ylabel("Median Salary")

plt.grid(True, color="grey", linestyle="-.")

plt.tight_layout()

plt.show()

data.tail()

#%%

# Histograms
# plt.style.use("fivethirtyeight")

data = pd.read_csv(r'./data3.csv')
ids = data['Responder_id']
ages = data['Age']
# ages = [18, 19, 21, 25, 26, 26, 30, 32, 38, 45, 55]
bins = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

plt.hist(ages, bins=bins, edgecolor='black', log=False)

median_age = 29
color = "#fc4f30"

plt.axvline(median_age, color=color, label='Age Median', linewidth=2)

plt.legend()

plt.title('Ages of Respondents')
plt.xlabel('Ages')
plt.ylabel('Total Respondents')

plt.tight_layout()
plt.show()

#%%
# Sactter Plots
# plt.style.use('seaborn')

x = [5, 7, 8, 5, 6, 7, 9, 2, 3, 4, 4, 4, 2, 6, 3, 6, 8, 6, 4, 1]
y = [7, 4, 3, 9, 1, 3, 2, 5, 2, 4, 8, 7, 1, 6, 4, 9, 7, 7, 5, 1]

colors = [7, 5, 9, 7, 5, 7, 2, 5, 3, 7, 1, 2, 8, 1, 9, 2, 5, 6, 7, 5]

sizes = [209, 486, 381, 255, 191, 315, 185, 228, 174,
        538, 239, 394, 399, 153, 273, 293, 436, 501, 397, 539]

plt.scatter(
    x, y,
    s=sizes,
    c=colors, 
    cmap='Greens',
    edgecolors='white', 
    linewidths=1, 
    alpha=0.75)#, marker='x')

cbar = plt.colorbar()
cbar.set_label('Satisfaction')

plt.tight_layout()

plt.show()

#%%
data = pd.read_csv('2019-05-31-data.csv')
view_count = data['view_count']
likes = data['likes']
ratio = data['ratio']

plt.scatter(
    view_count,
    likes,
    #s=sizes,
    c=ratio, 
    cmap='summer',
    edgecolors='white', 
    linewidths=1, 
    alpha=0.75)

cbar = plt.colorbar()
cbar.set_label('Ratio')

plt.xscale('log')
plt.yscale('log')

plt.title('Trending YouTube Videos')
plt.xlabel('View Count')
plt.ylabel('Total Likes')

plt.tight_layout()

plt.show()

#%%

# Matplotlib Tutorial (Part 8): Plotting Time Series Data

plt.style.use('seaborn')

dates = [
    datetime(2019, 5, 24),
    datetime(2019, 5, 25),
    datetime(2019, 5, 26),
    datetime(2019, 5, 27),
    datetime(2019, 5, 28),
    datetime(2019, 5, 29),
    datetime(2019, 5, 30),
]

y = [i for i in range(0, len(dates), 1)]

plt.plot_date(dates, y, linestyle='solid')

plt.gcf().autofmt_xdate()

date_format = mpl_dates.DateFormatter('%b, %d, %Y')

plt.gca().xaxis.set_major_formatter(date_format)

plt.tight_layout()
plt.show()
#%%

# Matplotlib Tutorial (Part 8): Plotting Time Series Data

data = pd.read_csv(r'./data4.csv')

data['Date'] = pd.to_datetime(data['Date'])
data.sort_values('Date', inplace=True)

price_date = data['Date']
price_close = data['Close']

plt.plot_date(price_date, price_close, linestyle='solid')

plt.gcf().autofmt_xdate()

plt.title('Bitcoin Prices')
plt.xlabel('Date')
plt.ylabel('Change Price')

plt.tight_layout()
plt.show()

#%%
# Subplots

plt.style.use('seaborn')

data = pd.read_csv('data6.csv')
ages = data['Age']
dev_salaries = data['All_Devs']
py_salaries = data['Python']
js_salaries = data['JavaScript']

fig, (ax1, ax2) = plt.subplots(nrows=2, ncols=1, sharex=True)

ax1.plot(ages, dev_salaries, label='All Dev', color='red')
ax2.plot(ages, py_salaries, label='Python', color='green')
ax2.plot(ages, js_salaries, label='Java', color='purple')

ax1.legend()

ax1.set_title('Median Salary')
ax1.set_ylabel('Salaries')

ax2.legend()

ax2.set_xlabel('Ages')
ax2.set_ylabel('Salaries')

plt.tight_layout()

plt.show()

#%%
plt.style.use('seaborn')

data = pd.read_csv('data6.csv')
ages = data['Age']
dev_salaries = data['All_Devs']
py_salaries = data['Python']
js_salaries = data['JavaScript']

fig1, ax1 = plt.subplots()
fig2, ax2 = plt.subplots()

ax1.plot(ages, dev_salaries, label='All Dev', color='red')
ax2.plot(ages, py_salaries, label='Python', color='green')
ax2.plot(ages, js_salaries, label='Java', color='purple')

ax1.legend()
ax1.set_title('Median Salary')
ax1.set_xlabel('Ages')
ax1.set_ylabel('Salaries')

ax2.legend()
ax2.set_title('Median Salary')
ax2.set_xlabel('Ages')
ax2.set_ylabel('Salaries')

plt.tight_layout()

plt.show()

fig1.savefig('x1x.png')
fig2.savefig('x2x.png')

#%%
