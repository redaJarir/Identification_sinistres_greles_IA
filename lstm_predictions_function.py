#libraries
import keras
import os
import numpy as np
import pandas as pd
#fonction de prédiction avec le modèle lstm
def predict_lstm(df):
  my_model = keras.models.load_model('My_model.h5')
  x = preparation(df)
  predictions=my_model.predict(x)
  pred = np.array(list(map(lambda x : 'grele' if x > 0.5 else 'non grele',predictions)))
  pred.tolist()
  df['lstm_class'] = pred
  return(df)

