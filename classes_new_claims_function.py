import pandas as pd
import pickle
import os
import openpyxl
 
def new_claims_class(file):
  
  df=pd.read_excel(file ,engine='openpyxl')
  
#  if os.path.isfile("classified_ID.pickle"):
#    with open('classified_ID.pickle', 'rb') as f:
#      ID_classified = pickle.load(f)
#      saved_ID_df=pd.DataFrame(ID_classified, columns=['ID_ADS'])
#      table_nouveaux_sinistres = df.merge(saved_ID_df['ID_ADS'], how = 'left' ,indicator=True).loc[lambda x : x['_merge']=='left_only'].drop('_merge', 1).reset_index(drop=True)
#      if table_nouveaux_sinistres.empty:
#        return('la table importée ne contient pas de nouveaux sinistres')
      
#     else:
#        class_new_claims=classifier(table_nouveaux_sinistres)
#        ID_classified=class_new_claims['ID_ADS'].to_list()
#        save_ID=saved_ID_df['ID_ADS'].to_list()+ID_classified
#        with open('classified_ID.pickle', 'wb') as f:
#          pickle.dump(save_ID, f)
#  else:
#    with open('classified_ID.pickle', 'wb') as f:
  class_new_claims=classifier(df)
#      ID_classified=class_new_claims['ID_ADS'].to_list()
#      pickle.dump(ID_classified, f)
  return(class_new_claims)
