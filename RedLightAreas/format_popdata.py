import numpy as np
import pandas as pd

# Regions to consider: Delhi (NCT), Nagpur (Maharastra), Mumbai (Maharastra), Kolkata (West Bengal)

# Reading raw data
Data = pd.read_excel('DDW-0000C-13.xls',skiprows=[0])
Data = Data[['State','Area Name','Age','Total']] # Keeping relevant columns
Data.drop([0,1,2,3,4],inplace=True) # Drop irrelevant rows
Data.set_index('State',inplace=True) # Make state codes index

# Initialize DataFrame for saving data
df = pd.DataFrame(columns=Data.index.unique())
# Group by population by grouping by each 5 years (0-4,5-9,10-14,...)
for ind in Data.index:
    temp = Data.loc[ind]
    temp = temp.iloc[1:-1]
    temp.reset_index(inplace=True)
    temp_ = temp.groupby(temp.index // 5).sum()
    temp_ = temp_['Total']
    df[ind] = temp_


df = df/df.sum()

temp = Data['Area Name'].unique()
for i in range(1,len(temp)):
    temp[i] = temp[i][8:-5]

df.columns = temp
df['TELANGANA'] = df['ANDHRA PRADESH'] # Assign same weights to Telangana as Andhra Pradesh

# Age-distribution for the four regions
df = df[['NCT OF DELHI','NCT OF DELHI',
         'WEST BENGAL','WEST BENGAL',
         'MAHARASHTRA','MAHARASHTRA',
         'MAHARASHTRA','MAHARASHTRA']]
# Creating an excel with names of states
# current population in Delhi, Delhi_RL, Kolkata,Kolkata_RL, Mumbai,Mumbai_RL, Nagpur,Nagpur_RL
pop = [10927986,1000,4631392,1000,12691836,1000,2228018,1000];

current_population = pd.Series(pop,index= df.columns)

# Save age-distributed data as excel
adf = df*current_population
adf.columns = ['Delhi','Delhi_RL','Kolkata','Kolkata_RL',
               'Mumbai','Mumbai_RL','Nagpur','Nagpur_RL']


adf.to_excel('Population_distribution.xlsx')
