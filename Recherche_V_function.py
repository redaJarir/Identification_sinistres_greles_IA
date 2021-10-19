#fonction de Recherche V
def Recherche_V(df):
  df['LI_DSC_ADS'] = df['LI_DSC_ADS'].astype(str)
  df['LI_DSC_SIGMA'] = df['LI_DSC_SIGMA'].astype(str)
  df['LI_CAUSE'] = df['LI_CAUSE'].astype(str)
  df['LI_DSC_ADS_1']=df['LI_DSC_ADS'].apply(replace_weird_words)
  df['LI_DSC_SIGMA_1']=df['LI_DSC_SIGMA'].apply(replace_weird_words)
  df['LI_CAUSE_1']=df['LI_CAUSE'].apply(replace_weird_words)
  df['Comment_RV'] = df.LI_DSC_SIGMA_1.str.cat(' '+df.LI_DSC_ADS_1 + ' '+df.LI_CAUSE_1)
  df['Comment_RV'] = df['Comment_RV'].apply(clean_comment)
  df['Comment_RV'] = df['Comment_RV'].str.replace('\d+', '')
  matches=['grel', 'grêl']
  for i in range (len(df)):
    df.loc[i, 'Comment_RV']=stem_comment(df.loc[i, 'Comment_RV'])
    if any(a in df.loc[i, 'Comment_RV'] for a in matches):
        df.loc[i, 'Recherche_V_class']='grele'
    else:
        df.loc[i, 'Recherche_V_class']='non grele'
  return(df)

