import pip
pip.main(["install", "plotly"])

import plotly
import plotly.plotly as py
import pandas as pd
import numpy as np

# refs: 
# https://plot.ly/python/lines-on-maps/
# https://plot.ly/python/reference/#scattergeo

path = "C:\\work\\projetos\\ie-ds-bootcamp\\ie-ds-bc-group3\\data\\"

# 'IATA', 'Latitude', 'Longitude', 'Name', 'City', 'Country'
airports = pd.read_csv(path + "plotly_airports.csv", encoding = 'utf8')

# 'ORIGIN', 'DEST', 'DELAYS', 'ON_TIME', 'FLIGHTS', 'DELAY_RATIO'
flight_legs = pd.read_csv(path + "plotly_flights.csv", encoding = 'utf8')
flight_legs = flight_legs.head(800) # get the first 800 only

layout = dict(
        title = 'Aug-2017 USA Flights',
        showlegend = False,
        geo = dict(
            scope='north america', # "world" | "usa" | "europe" | "asia" | "africa" | "north america" | "south america"
            projection=dict( type='mercator' ), # "equirectangular" | "mercator" | "orthographic" | "natural earth" | "kavrayskiy7" | "miller" | "robinson" | "eckert4" | "azimuthal equal area" | "azimuthal equidistant" | "conic equal area" | "conic conformal" | "conic equidistant" | "gnomonic" | "stereographic" | "mollweide" | "hammer" | "transverse mercator" | "albers usa" | "winkel tripel" | "aitoff" | "sinusoidal"
            showland = True,
            landcolor = 'grey', 
            countrycolor = 'white',
        )
    )
       
airports_dict = [ dict(
        type = 'scattergeo', # type for maps - https://plot.ly/python/reference/#scattergeo
        locationmode = 'USA-states', # "ISO-3" | "USA-states" | "country names"
        lon = airports.Longitude,
        lat = airports.Latitude,
        mode = 'markers', # combination of "lines", "markers", "text" joined with a "+" OR "none"
        marker = {'size':2, 'color':'blue'},
        text = airports.Name,
        hoverinfo = 'text',
        )]

# just the airports
# step1 = dict( data = airports_dict, layout=layout )
# plotly.offline.plot(step1, filename='d3-flight-paths' )

flight_paths = []
for i in range( len( flight_legs ) ):
    origin = airports.loc[airports.IATA == flight_legs.loc[i,"ORIGIN"]]
    destination = airports.loc[airports.IATA == flight_legs.loc[i,"DEST"]]
    color = 'red' if flight_legs.loc[i,"DELAY_RATIO"] < 20 else 'green'
    
    flight_paths.append(
        dict(
            type = 'scattergeo', # type for maps - https://plot.ly/python/reference/#scattergeo
            locationmode = 'USA-states', # "ISO-3" | "USA-states" | "country names"
            lat = [ origin.Latitude.iloc[0], destination.Latitude.iloc[0] ],
            lon = [ origin.Longitude.iloc[0], destination.Longitude.iloc[0] ],
            mode = 'lines', # combination of "lines", "markers", "text" joined with a "+" OR "none"
            line = {'width': 1, 'color': color},
            opacity = flight_legs.loc[i,"DELAY_RATIO"]/100,
        )
    )

# the airports and the connections
step2 = dict( data = airports_dict + flight_paths, layout=layout )
plotly.offline.plot(step2, filename='d3-flight-paths' )

# host it online
# plotly.tools.set_credentials_file(username='homemdasneves', api_key='wF0KHA0nQPgIGm0Qrqju')
# py.iplot( fig, filename='d3-flight-paths' )
