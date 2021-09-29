import pickle5 as pickle
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
max_length = 10
def preparation(df):
  df
  BD = []
  BD=pd.DataFrame(BD)
  df.loc[df['LI_DSC_SIGMA'].isnull(), 'LI_DSC_SIGMA']=df['LI_DSC_ADS']
  df.rename(columns={'LI_DSC_SIGMA': 'Comment'}, inplace=True)
  BD['Comment'] = df['Comment'].apply(clean_comment)
  BD['Comment'] = BD['Comment'].str.replace('\d+', '')
  for i in range (0,len(BD)):
    BD.loc[i, 'Comment']=stem_comment(BD.loc[i, 'Comment'])
  with open('tokenizer.pickle', 'rb') as handle:
    tokenizer = pickle.load(handle)
    X = tokenizer.texts_to_sequences(df["Comment"].to_numpy())
    X = pad_sequences(X, maxlen=max_length,truncating="post", padding="post")
    return(X)
