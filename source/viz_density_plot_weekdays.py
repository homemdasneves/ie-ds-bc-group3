# -*- coding: utf-8 -*-
"""
Created on Mon Nov 13 23:06:26 2017

@author: homemdasneves
"""

import seaborn as sns



path = "C:\\work\\projetos\\ie-ds-bootcamp\\ie-ds-bc-group3\\data\\"
data = pd.read_csv(path + "year.csv")

data.MONTH.unique()

data["DELAYS"] = list(map(lambda x: True if x > 15 else False, data.ARR_DELAY))
data["FLIGHTS"] = 1

data_viz = data.loc[:,["MONTH","DAY_OF_WEEK","DELAYS","FLIGHTS"]]
data_viz = data_viz.groupby(by=["MONTH","DAY_OF_WEEK"], as_index=False).sum()
data_viz["DELAY_RATIO"] = data_viz["DELAYS"] / data_viz["FLIGHTS"]
data_viz 
    


ggplot(data_viz, aes("DAY_OF_WEEK", "DELAY_RATIO",colour = "MONTH")) +\
    geom_point()
 
# TODO: 
# connect the points
# change the color scale
# put all the 12 months in the scale    
    
# "1","Monday"
# "2","Tuesday"
# "3","Wednesday"
# "4","Thursday"
# "5","Friday"
# "6","Saturday"
# "7","Sunday"