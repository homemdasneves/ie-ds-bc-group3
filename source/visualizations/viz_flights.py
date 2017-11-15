import pip
pip.main(["install", "plotly"])

import plotly
import plotly.plotly as py
import pandas as pd

# 'IATA', 'Latitude', 'Longitude', 'Name', 'City', 'Country'
airports = pd.read_csv(path + "plotly_airports.csv", encoding = 'utf8')
airports.columns

# 'ORIGIN', 'DEST', 'DELAYS', 'ON_TIME', 'FLIGHTS', 'DELAY_RATIO'
flight_legs = pd.read_csv(path + "plotly_flights.csv", encoding = 'utf8')
flight_legs = flight_legs.head(800)
flight_legs.shape

path = "C:\\work\\projetos\\ie-ds-bootcamp\\ie-ds-bc-group3\\data\\"
data = pd.read_csv(path + "Aug_2017.csv")
data.head(4).transpose()

airports_dict = [ dict(
        type = 'scattergeo',
        locationmode = 'USA-states',
        lon = airports.Longitude,
        lat = airports.Latitude,
        text = airports.Name,
        hoverinfo = 'text',
        mode = 'markers',
        marker = {'size':2, 'color':'blue'} # rgb(243, 243, 243)
        )]
        
flight_paths = []
for i in range( len( flight_legs ) ):
    origin = airports.loc[airports.IATA == flight_legs.loc[i,"ORIGIN"]]
    destination = airports.loc[airports.IATA == flight_legs.loc[i,"DEST"]]
    
    flight_paths.append(
        dict(
            type = 'scattergeo',
            locationmode = 'USA-states',
            lon = [ origin.Longitude.iloc[0], destination.Longitude.iloc[0] ],
            lat = [ origin.Latitude.iloc[0], destination.Latitude.iloc[0] ],
            mode = 'lines',
            line = {'width': 1, 'color': 'red'},
            opacity = flight_legs.loc[i,"DELAY_RATIO"],
        )
    )
    
layout = dict(
        title = 'Aug-2017 USA Flights',
        showlegend = False, 
        geo = dict(
            scope='north america', # "world" | "usa" | "europe" | "asia" | "africa" | "north america" | "south america"
            projection=dict( type='azimuthal equal area' ), # "equirectangular" | "mercator" | "orthographic" | "natural earth" | "kavrayskiy7" | "miller" | "robinson" | "eckert4" | "azimuthal equal area" | "azimuthal equidistant" | "conic equal area" | "conic conformal" | "conic equidistant" | "gnomonic" | "stereographic" | "mollweide" | "hammer" | "transverse mercator" | "albers usa" | "winkel tripel" | "aitoff" | "sinusoidal"
            showland = True,
            landcolor = 'rgb(243, 243, 243)', 
            countrycolor = 'rgb(204, 204, 204)',
        )
    )
    
fig = dict( data = flight_paths + airports_dict, layout=layout )
plotly.offline.plot( fig, filename='d3-flight-paths' )

# for web hosting 
# plotly.tools.set_credentials_file(username='homemdasneves', api_key='wF0KHA0nQPgIGm0Qrqju')
# py.iplot( fig, filename='d3-flight-paths' )


# original flights

#df_flight_paths = pd.read_csv('https://raw.githubusercontent.com/plotly/datasets/master/2011_february_aa_flight_paths.csv')
#df_flight_paths.head(6).transpose()
#
#flight_paths = []
#for i in range( len( df_flight_paths ) ):
#    flight_paths.append(
#        dict(
#            type = 'scattergeo',
#            locationmode = 'USA-states',
#            lon = [ df_flight_paths['start_lon'][i], df_flight_paths['end_lon'][i] ],
#            lat = [ df_flight_paths['start_lat'][i], df_flight_paths['end_lat'][i] ],
#            mode = 'lines',
#            line = {'width': 1, 'color': 'red'},
#            opacity = float(df_flight_paths['cnt'][i])/float(df_flight_paths['cnt'].max()),
#        )
#    )