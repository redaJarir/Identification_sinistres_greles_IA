#libraries
import pickle5 as pickle

from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
#fonction pour préparer les données au traitement par le modèle lstm
max_length = 10
def preparation(df):
  df['LI_DSC_ADS'] = df['LI_DSC_ADS'].astype(str)
  df['LI_DSC_SIGMA'] = df['LI_DSC_SIGMA'].astype(str)
  df['LI_CAUSE'] = df['LI_CAUSE'].astype(str)
  df['Comment'] = df.LI_DSC_SIGMA.str.cat(' '+df.LI_DSC_ADS+' '+df.LI_CAUSE)
  df['Comment'] = df['Comment'].apply(clean_comment)
  df['Comment'] = df['Comment'].str.replace('\d+', '')
  for i in range (len(df)):
    df.loc[i, 'Comment']=stem_comment(df.loc[i, 'Comment'])
  with open('tokenizer.pickle', 'rb') as handle:
    tokenizer = pickle.load(handle)
    X = tokenizer.texts_to_sequences(df["Comment"].to_numpy())
    X = pad_sequences(X, maxlen=max_length,truncating="post", padding="post")
  return(X)
