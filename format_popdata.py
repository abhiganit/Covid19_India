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



# calculation for spatial matrix
air = pd.read_excel('States_connection.xlsx','Air')
rail = pd.read_excel('States_connection.xlsx','Rail')
space = pd.read_excel('States_connection.xlsx','Spatial')

# Probability of travel:
pT = 0.05;
pA = 0.05;
pR = 0.45;
pS = 0.5;

# Adjusting matrices for outward travels
temp = air.sum(axis=1) - np.diag(air)
air = air.div(temp,axis=1)
air.fillna(0,inplace=True)
temp = rail.sum(axis=1) - np.diag(rail)
rail = rail.div(temp,axis=1)
rail.fillna(0,inplace=True)
temp = space.sum(axis=1) - np.diag(space)
space = space.div(temp,axis=1)
space.fillna(0,inplace=True)

# spatial connection matrix
S = pT*(pA*air+pR*rail+pS*space)
temp = np.fill_diagonal(S.values,1)

pT*(pA*air.iloc[0]['Jammu and Kashmir']+ pR*rail.iloc[0]['Jammu and Kashmir'] + pS*space.iloc[0]['Jammu and Kashmir'])
