#Libraries
from nltk.stem import SnowballStemmer
from nltk.tokenize import word_tokenize
#fonction pour faire le stemming
stemmer_ss = SnowballStemmer("french")
def stem_comment(comment):
    token_words=word_tokenize(comment)
    stem_comment=[]
    for word in token_words:
        stem_comment.append(stemmer_ss.stem(word))
        word_index = token_words.index(word)
        if word_index != len(token_words)-1:
            stem_comment.append(" ") 
    return "".join(stem_comment)
