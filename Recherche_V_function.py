#fonction de Recherche V
def Recherche_V(df):
  df['LI_DSC_ADS'] = df['LI_DSC_ADS'].astype(str)
  df['LI_DSC_SIGMA'] = df['LI_DSC_SIGMA'].astype(str)
  df['LI_CAUSE'] = df['LI_CAUSE'].astype(str)
  df['Comment'] = df.LI_DSC_SIGMA.str.cat(' '+df.LI_DSC_ADS + ' '+df.LI_CAUSE)
  df['Comment'] = df['Comment'].apply(clean_comment)
  df['Comment'] = df['Comment'].str.replace('\d+', '')
  matches=['grel', 'grêl', 'gr^l']
  for i in range (len(df)):
    df.loc[i, 'Comment']=stem_comment(df.loc[i, 'Comment'])
    if any(a in df.loc[i, 'Comment'] for a in matches):
        df.loc[i, 'Recherche_V_class']='grele'
    else:
        df.loc[i, 'Recherche_V_class']='non grele'
  return(df)
