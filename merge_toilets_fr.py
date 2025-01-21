from geopy import distance
import csv

# Load in all of the polling stations
with open('data/polling_places.csv', encoding='utf-8') as file:
    polling_stations = list(csv.DictReader(file))

# Find the closest polling station to each toilet
with open('data/toilets.csv', encoding='utf-8') as file:
    reader = csv.DictReader(file)
    # One by one
    for toilet in reader:
        shortest_distance = float('inf')
        closest_station = None
        for station in polling_stations:
            polling_distance = distance.distance(
                (toilet["Latitude"], toilet["Longitude"]),
                (station["Latitude"], station["Longitude"])
            )
            if polling_distance < shortest_distance:
                closest_station = station
                shortest_distance = polling_distance


# distance.distance(x, y)