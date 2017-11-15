# -*- coding: utf-8 -*-
"""
Created on Mon Nov 13 14:57:55 2017

@author: homemdasneves
"""

# create a chord diagram with relationships between bootcampers
import random 
import pandas as pd
import matplotlib as plt

from bokeh.io import show
from bokeh.charts import Chord

path = "C:\\work\\projetos\\ie-ds-bootcamp\\ie-ds-bc-group3\\data\\"
data = pd.read_csv(path + "Aug_2017.csv")

aux = data.head(5)

NUM_ORIG_DESTS = 50
SORT_BY_AVG = "ARR_DELAY"

data_aux = data.groupby(by=["ORIGIN", "DEST"], as_index=False).mean() \
    .sort_values(by = [SORT_BY_AVG], ascending=[False]).head(NUM_ORIG_DESTS)

data_aux[SORT_BY_AVG + "_INT"] = data_aux[SORT_BY_AVG].astype(int)

chord_from_df2 = Chord(data_aux, source="ORIGIN", target="DEST", value=SORT_BY_AVG + "_INT")
show(chord_from_df2)

