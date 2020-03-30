import numpy as np
import pandas as pd

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

# Creating an excel with names of states
current_population = pd.Series(index= df.columns)

current_population = pd.read_excel('current_population.xlsx')
current_population.set_index('State',inplace=True)


# Save age-distributed data as excel
adf = df*current_population.Population
adf.to_excel('Population_distribution.xlsx')
