import csv
import json

state_toilets = {}
toilet_aggregation_columns = [
    "Male", "Female", "Unisex", "AllGender",
    "ParkingAccessible", "PaymentRequired",
    "AdultChange", "BabyChange", "BabyCareRoom",
    "Accessible", "SanitaryDisposal", "MensPadDisposal"
]

# Map states to toilets
with open('data/toilets.csv', encoding='utf-8') as file:
    reader = csv.DictReader(file)
    # One by one
    for toilet in reader:
        state = toilet['State']

        # Toilet aggregates
        if state not in state_toilets:
            # Init all column names to 0
            state_toilets[state] = {
                column: 0
                for column in toilet_aggregation_columns
            }
            state_toilets[state]["State"] = state
            state_toilets[state]["Total"] = 0
        
        # Tally for any property that is "True" for this toilet
        state_toilets[state]["Total"] += 1
        for column in toilet_aggregation_columns:
            if toilet[column] == "True":
                state_toilets[state][column] += 1

# Loop over all of the collected toilet aggregates and normalize
for state, toilet_statistics in state_toilets.items():
    total = toilet_statistics['Total']
    # For each of the aggregated columns, divide by total # of columns
    for column in toilet_aggregation_columns:
        toilet_statistics[column] /= total

# Write results to json file
with open("data/toilet_states.json", "w") as f:
    json.dump(state_toilets, f, indent=4)

# Write results to csv file
with open("data/toilet_states.csv", "w", newline="") as file:
    writer = csv.DictWriter(file, ["State", "Total", *toilet_aggregation_columns])
    writer.writeheader()
    writer.writerows(state_toilets.values())
