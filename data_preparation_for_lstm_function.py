#libraries
import pickle

from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
#fonction pour préparer les données au traitement par le modèle lstm
max_length = 10
def preparation(df):
  df['LI_DSC_ADS'] = df['LI_DSC_ADS'].astype(str)
  df['LI_DSC_SIGMA'] = df['LI_DSC_SIGMA'].astype(str)
  df['Comment_lstm'] = df.LI_DSC_SIGMA.str.cat(' '+df.LI_DSC_ADS)
  df['Comment_lstm'] = df['Comment_lstm'].apply(clean_comment)
  df['Comment_lstm'] = df['Comment_lstm'].str.replace('\d+', '')
  for i in range (len(df)):
    df.loc[i, 'Comment_lstm']=stem_comment(df.loc[i, 'Comment_lstm'])
  with open('tokenizer.pickle', 'rb') as handle:
    tokenizer = pickle.load(handle)
    X = tokenizer.texts_to_sequences(df["Comment_lstm"].to_numpy())
    X = pad_sequences(X, maxlen=max_length,truncating="post", padding="post")
  return(X)
