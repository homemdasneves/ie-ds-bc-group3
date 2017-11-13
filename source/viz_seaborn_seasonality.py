# -*- coding: utf-8 -*-
"""
Created on Mon Nov 13 00:58:24 2017

@author: homemdasneves
"""

# day | month | value (number delays)

import pandas as pd
import seaborn as sns
#from bokeh.io import show
#from bokeh.charts import output_file, Chord

path = "C:\\work\\projetos\\ie-ds-bootcamp\\ie-ds-bc-group3\\data\\"
data = pd.read_csv(path + "year.csv")

data.MONTH.unique()
data.columns

data["DAY"] = list(map(lambda x: int(x.split("-")[-1]), data.FL_DATE))
data["DELAYS"] = list(map(lambda x: True if x > 15 else False, data.ARR_DELAY))

data_viz = data.loc[:,["DAY","MONTH","DELAYS"]]
data_viz = data_viz.groupby(by=["DAY","MONTH"], as_index=False).sum()
data_viz = data_viz.pivot(index = 'MONTH', columns = 'DAY', values='DELAYS')

heatmap = sns.heatmap(data_viz, cmap="YlGnBu", annot=True, linewidth=0.5)

figure = heatmap.get_figure()
figure.set_size_inches(11.7, 8.27)
figure.savefig(path + "seasonality.jpg")



