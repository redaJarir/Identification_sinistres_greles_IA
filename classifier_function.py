
def classifier(df):
  df_Recherche_V = Recherche_V(df)
  df_lstm = predict(df)
  for i in range (len(df_Recherche_V)):
    if df_Recherche_V.loc[i, 'Recherche_V_class']=='grele' and df_lstm.loc[i, 'lstm_class']=='grele':
      df.loc[i, 'Class']='grele'
    elif df_Recherche_V.loc[i, 'Recherche_V_class']=='non grele' and df_lstm.loc[i, 'lstm_class']=='grele':
      df.loc[i, 'Class']='non grele'
    elif df_Recherche_V.loc[i, 'Recherche_V_class']=='non grele' and df_lstm.loc[i, 'lstm_class']=='non grele': 
      df.loc[i, 'Class']='non grele'
    elif df_Recherche_V.loc[i, 'Recherche_V_class']=='grele' and df_lstm.loc[i, 'lstm_class']=='non grele':
      df.loc[i, 'Class']='sinistre à vérifier'
  return(df)
