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
data = pd.read_csv(path + "train2.csv")

data.MONTH.unique()
data.columns

data["DAY"] = list(map(lambda x: int(x.split("-")[-1]), data.FLIGHT_DATE))
data["DELAYS"] = list(map(lambda x: True if x > 15 else False, data.ARRIVAL_DELAY))

data_viz = data.loc[:,["DAY","MONTH","DELAYS"]]
data_viz = data_viz.groupby(by=["DAY","MONTH"], as_index=False).sum()
data_viz = data_viz.pivot(index = 'MONTH', columns = 'DAY', values='DELAYS')

weekdays = data.loc[:,["DAY","MONTH","DAY_OF_WEEK"]]
weekdays = weekdays.groupby(by=["DAY","MONTH"], as_index=False).mean()
weekdays["WEEKEND"] = list(map(lambda x: "Sun" if x == 7 else ("Sat" if x == 6 else ""), weekdays["DAY_OF_WEEK"]))

weekdays = weekdays.pivot(index = 'MONTH', columns = 'DAY', values='WEEKEND')

our_palette = reversed(["#FF4C72","#E64773","#CE4375","#B63F77","#9D3A79",
                        "#85367A","#6D327C","#542D7E","#3C2980","#242582"])
light_blue_pink = reversed(["#bf1878","#d964a4","#eba3cd","#f8d1e7","#f9ecf3", 
                    "#e5eef3","#cde9f2","#9acce1","#6aa2cb", "#436eb0"])
our_pallete_light_center = reversed(["#FF4C72","#F87492","#F29DB2","#EBC5D2","#E5EEF3",
                    "#BEC5DC","#979DC5","#7175AF","#4A4D98","#242582"])
our_pink_light_blue = reversed(["#FF4C72","#F87492","#F29DB2","#EBC5D2","#EACDD9",
                    "#e5eef3","#cde9f2","#9acce1","#6aa2cb", "#436eb0"])

custom_style = {'axes.labelcolor':'black','xtick.color':'black','ytick.color':'black'}
sns.set_style("whitegrid", rc=custom_style)
sns.set_context('notebook', font_scale=1.5, rc={})

heatmap = sns.heatmap(data_viz, \
    cmap=sns.color_palette(our_pink_light_blue, n_colors = 10), \
    annot=weekdays, fmt="s",\
    annot_kws={"rotation": 90},\
    cbar_kws={'label': 'Delays'})

figure = heatmap.get_figure()
figure.set_size_inches(1.5*11.7, 1.5*8.27)
figure.savefig(path + "seasonality.png", transparent=True)
figure


#our_pink_light_blue = reversed(["#FF4C72","#F87492","#F29DB2","#EBC5D2","#EACDD9",
#                    "#e5eef3","#cde9f2","#9acce1","#6aa2cb", "#436eb0"])

#sns.set_style("darkgrid")
#heatmap = sns.heatmap(data_viz, \
#    cmap=sns.color_palette(our_pink_light_blue, n_colors = 10), \
#    annot=weekdays, linewidth=0.5, fmt="s", \
#    annot_kws={"rotation": 90})