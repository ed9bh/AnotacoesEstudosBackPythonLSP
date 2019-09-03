#%%
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

#%%
# Plotting Live Data in Real-Time

plt.style.use("fivethirtyeight")
"""
x_vals = []
y_vals = []

index = count()


def animate(i):
    x_vals.append(next(index))
    y_vals.append(random.randint(0, 5))

    plt.cla()
    plt.plot(x_vals, y_vals)
    pass


ani = FuncAnimation(plt.gcf(), animate, interval=1000)

plt.tight_layout()
plt.show()
"""

#%%
x_vals = []
y_vals = []

index = count()


def animate(i):
    data = pd.read_csv(r"./data5.csv")
    x = data["x_value"]
    y1 = data["total_1"]
    y2 = data["total_2"]

    plt.cla()
    plt.plot(x, y1, label="Line 01")
    plt.plot(x, y2, label="Line 02")

    plt.legend(loc='upper left')
    plt.tight_layout()
    pass


ani = FuncAnimation(plt.gcf(), animate, interval=1000)

plt.show()
