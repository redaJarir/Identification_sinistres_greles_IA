import pickle5 as pickle
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences

max_length = 10
def preparation(df):
  df=pd.read_csv('test1.csv', sep=';', encoding = "ISO-8859-1")
  df.loc[df['LI_DSC_SIGMA'].isnull(), 'LI_DSC_SIGMA']=df['LI_DSC_ADS']
  df.rename(columns={'LI_DSC_SIGMA': 'Comment'}, inplace=True)
  df['Comment'] = df['Comment'].apply(clean_comment)
  df['Comment'] = df['Comment'].str.replace('\d+', '')
  for i in range (len(df)):
    df.loc[i, 'Comment']=stem_comment(df.loc[i, 'Comment'])
  with open('tokenizer.pickle', 'rb') as handle:
    tokenizer = pickle.load(handle)
    X = tokenizer.texts_to_sequences(df["Comment"].to_numpy())
    X = pad_sequences(X, maxlen=max_length,truncating="post", padding="post")
  return(X)
