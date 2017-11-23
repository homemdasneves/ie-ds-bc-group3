# -*- coding: utf-8 -*-
"""
Created on Wed Nov 15 15:47:08 2017

@author: homemdasneves
"""

path = "C:\\work\\projetos\\ie-ds-bootcamp\\ie-ds-bc-group3\\data\\"
data = pd.read_csv(path + "Aug_2017.csv")
data.columns

our_airports = data.ORIGIN.unique()

# get a csv with airports and their coordinates
airport_data = pd.read_csv('https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat')
airport_data.columns = ['Airport_ID','Name','City','Country','IATA','ICAO','Latitude','Longitude','Altitude','Timezone','DST','Tz','Type','Source']
airport_data.head()
usa_airports = airport_data.loc[airport_data.IATA.isin(our_airports), ["IATA", "Latitude", "Longitude","Name","City", "Country"]]
usa_airports.Name = list(map(lambda x: x.replace(" Airport", ""), usa_airports.Name))

# there's one airport missing: IFP
set(our_airports) - set(usa_airports.IATA)
usa_airports = usa_airports.append({'IATA': 'IFP', 'Latitude': 35.156111, 'Longitude': -114.559444, 'Name': 'Laughlin/Bullhead', 'City': 'Bullhead City', 'Country': 'United States'}, ignore_index = True)

usa_airports.to_csv(path + "plotly_airports.csv", encoding = 'utf8')

# get data like: 'ORIGIN', 'DEST', 'DELAYS', 'ON_TIME', 'FLIGHTS', 'DELAY_RATIO'
data["DELAYS"] = list(map(lambda x: True if x > 15 else False, data.ARR_DELAY))
data["ON_TIME"] = list(map(lambda x: True if x <= 15 else False, data.ARR_DELAY))
data["FLIGHTS"] = 1

data_viz = data.groupby(by=["ORIGIN", "DEST"], as_index=False)["DELAYS","ON_TIME","FLIGHTS"].sum()

data_viz["DELAY_RATIO"] = 100 * data_viz.DELAYS / data_viz.FLIGHTS
data_viz = data_viz.sort_values("FLIGHTS", ascending=False)

data_viz.to_csv(path + "plotly_flights.csv", encoding = 'utf8')