import keras
import os
import numpy as np
import pandas as pd
def predict(df):
  BD = pd.DataFrame(df)
  my_model = keras.models.load_model('My_model.h5')
  x = preparation(BD)
  predictions=my_model.predict(x)
  pred = np.array(list(map(lambda x : 'grele' if x > 0.5 else 'non grele',predictions)))
  pred.tolist()
  df['lstm_class'] = pred
  return(df)

df=pd.read_csv('test1.csv', sep=';', encoding = "ISO-8859-1")
df
predict(df)
