#!/usr/bin/python

import csv
import sys
import pandas as pd
pd.set_option("display.max_rows", None, "display.max_columns", None)
from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import LabelEncoder

data_filename=sys.argv[1]

player_data = pd.read_csv(data_filename, delimiter=',')

#print(player_data.columns)
#print(player_data.head())

label_encoder = LabelEncoder()
integer_encoded = label_encoder.fit_transform(player_data.eventname)
player_data["eventname_encoded"]=integer_encoded
player_data=player_data.drop('eventname',axis=1)
#print(player_data.columns)
player_data.to_csv('/percona/results.csv',index=False)
