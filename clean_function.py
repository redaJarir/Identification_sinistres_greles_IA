#Libraries
import re
import nltk
from nltk.corpus import stopwords
#les caractères à enlever 
REPLACE_BY_SPACE_RE = re.compile('[/(){}\[\]\|@,;:!?]')
#Importer la liste des stopwords en français 
STOPWORDS = nltk.corpus.stopwords.words('french')
#Liste des mots à ajouter dans la liste des stopwords en français
words_to_add=['fiche', 'db', 'dpt', 'neant', 'nan']
for word in words_to_add:
  STOPWORDS.append(word)
#mots à enlever de la liste des stopwords en français
STOPWORDS.remove('pas')
#fonction pour faire le cleaning
def clean_comment(comment):
  comment = REPLACE_BY_SPACE_RE.sub(' ', comment) # replace REPLACE_BY_SPACE_RE symbols by space in text. substitute the matched string in REPLACE_BY_SPACE_RE with space. 
  comment = ' '.join(word for word in comment.split() if word not in STOPWORDS) # remove stopwors from text
  return comment
