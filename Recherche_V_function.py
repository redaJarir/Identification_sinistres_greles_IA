
def Recherche_V(df):
  BD=pd.DataFrame(df)
  BD.loc[df['LI_DSC_SIGMA'].isnull(), 'LI_DSC_SIGMA']=BD['LI_DSC_ADS']
  BD.rename(columns={'LI_DSC_SIGMA': 'Comment'}, inplace=True)
  BD['Comment'] = BD['Comment'].apply(clean_comment)
  BD['Comment'] = BD['Comment'].str.replace('\d+', '')
  for i in range (len(BD)):
    BD.loc[i, 'Comment']=stem_comment(BD.loc[i, 'Comment'])
    a='grel' in BD.loc[i, 'Comment']
    if a==0:
        df.loc[i, 'Recherche_V_class']='non grele'
    else:
        df.loc[i, 'Recherche_V_class']='grele'
  return(df)
