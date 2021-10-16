import pandas as pd
import pickle5 as pickle
import os
def final_class(df):
  if os.path.isfile("ID_classified.pickle"):
    with open('ID_classified.pickle', 'rb') as f:
        ID_classified = pickle.load(f)
        saved_ID_df=pd.DataFrame(ID_classified, columns=['ID_ADS'])
        table_nouveaux_sinistres = df.merge(saved_ID_df['ID_ADS'], how = 'left' ,indicator=True).loc[lambda x : x['_merge']=='left_only'].drop('_merge', 1).reset_index(drop=True)
        bd=classifier(table_nouveaux_sinistres)
        ID_classified=bd['ID_ADS'].to_list()
        saved_ID=saved_ID_df['ID_ADS'].to_list()+ID_classified
    with open('ID_classified.pickle', 'wb') as f:
        pickle.dump(saved_ID, f)
  else:
    with open('ID_classified.pickle', 'wb') as f:
      bd=classifier(df)
      ID_classified=bd['ID_ADS'].to_list()
      pickle.dump(ID_classified, f)
  return(bd)

