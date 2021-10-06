import pandas as pd
def nv_sinistres(df_n,df_n_1):
  table_nouveaux_sinistres = df_n.merge(df_n_1['ID_ADS'], how = 'left' ,indicator=True).loc[lambda x : x['_merge']=='left_only'].drop('_merge', 1).reset_index(drop=True)
  return(table_nouveaux_sinistres)


