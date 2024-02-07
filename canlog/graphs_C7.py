import os
import sys
import pandas as pd
import matplotlib.pyplot as plt
from tkinter import filedialog as fd

inFile = fd.askopenfilename()
data = pd.read_excel(inFile)
data.set_index("Time", inplace=True)

fig, axes = plt.subplots(nrows=2, ncols=1)

spd = data['Speed']
mreal = data[['Mreal', 'M_upr']]
spd.plot(ax=axes[0]) # .plot - это функция Pandas, а не matplotlib
mreal.plot(ax=axes[1])
plt.show()

# axs = data[['Mreal', 'M_upr']].plot.area(figsize=(12,4), subplots=True)