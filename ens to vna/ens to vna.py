# ens to vna
# this script takes the ens phone export (phone / authorized callers) as first argument
# and take the vna directory export as second argument
#
# This script will look for a match of extension number between the 2 files , then take the zone of the first
# file and assign it to the location of the 2nd one. This is to help import users and their locations.
#


import pandas as pd

# Load the two files into dataframes, ensuring all columns are treated as text
file1_path = '/mnt/data/ens phone.csv'
file2_path = '/mnt/data/vna exportedDirectories_SHUFSD_.csv'

file1_df = pd.read_csv(file1_path, dtype=str)
file2_df = pd.read_csv(file2_path, dtype=str)

# Merge the two dataframes based on matching 'calling_number' from file1 and 'number' from file2
merged_df = pd.merge(file1_df, file2_df, left_on='calling_number', right_on='number', how='left')

# Create a copy of file2_df to make the output file
output_df = file2_df.copy()

# Update the 'location' in the output file with 'zone_id' from file1
output_df['location'] = output_df.apply(
    lambda row: merged_df[merged_df['number'] == row['number']]['zone_id'].values[0]
    if row['number'] in merged_df['number'].values else row['location'],
    axis=1
)

import ace_tools as tools; tools.display_dataframe_to_user(name="Updated Output File", dataframe=output_df)

# Save the updated output file
output_file_path = '/mnt/data/updated_output_file.csv'
output_df.to_csv(output_file_path, index=False)

output_file_path
