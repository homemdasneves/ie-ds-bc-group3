# -*- coding: utf-8 -*-
"""
Created on Sat Nov 11 11:08:28 2017

@author: homemdasneves
"""

import pandas as pd
import seaborn as sns
#from bokeh.io import show
#from bokeh.charts import output_file, Chord

path = "C:\\work\\projetos\\ie-ds-bootcamp\\ie-ds-bc-group3\\data\\"
data = pd.read_csv(path + "Aug_2017.csv")

data_subset = data.loc[:,["DAY_OF_WEEK","UNIQUE_CARRIER","FL_NUM","ORIGIN","DEST","CRS_DEP_TIME","DEP_TIME","DEP_DELAY","CRS_ARR_TIME","ARR_TIME","ARR_DELAY","CANCELLED","DIVERTED","DISTANCE"]]
corr = data_subset.corr()

heatmap = sns.heatmap(corr, cmap="YlGnBu", annot=True, linewidth=0.5)

figure = heatmap.get_figure()
figure.set_size_inches(11.7, 8.27)
figure.savefig(path + "corr_heatmap.png")

figure


