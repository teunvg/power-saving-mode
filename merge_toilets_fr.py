from geopy.distance import geodesic as geodesic_distance
import csv

def manhattan_distance(toilet, station):
    return abs(toilet[0] - station[0]) + abs(toilet[1] - station[1])

# Load in all of the polling stations
with open('data/polling_place.csv', encoding='utf-8') as file:
    polling_stations = list(csv.DictReader(file))

# Find the closest polling station to each toilet
toilet_polling_mapping = []
with open('data/toilets.csv', encoding='utf-8') as file:
    reader = csv.DictReader(file)
    # One by one
    for toilet in reader:
        shortest_distance = float('inf')
        closest_station = None
        for station in polling_stations:
            try:
                toilet_location = (float(toilet["Latitude"]), float(toilet["Longitude"]))
                station_location = (float(station["Latitude"]), float(station["Longitude"]))
                bad_polling_distance = manhattan_distance(toilet_location, station_location)
                if bad_polling_distance < 1:
                    polling_distance = geodesic_distance(toilet_location, station_location).km
                    if polling_distance < shortest_distance:
                        closest_station = station
                        shortest_distance = polling_distance
            except:
                pass
        
        # Add it to the results list
        toilet_polling_mapping.append((
            toilet['FacilityID'],
            closest_station['PollingPlaceID'] if closest_station else None,
            shortest_distance
        ))

# Save the toilet mapping
with open("data/toilet_polling_station_mapping.csv", "w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(("FacilityID", "PollingPlaceID", "Distance"))
    writer.writerows(toilet_polling_mapping)