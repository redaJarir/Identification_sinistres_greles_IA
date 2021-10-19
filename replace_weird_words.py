
def replace_weird_words(comment):
  ecritures_bizarres=['gr\x88le', 'grele', 'gêle', 'gr le','grële', 'grle', 'gr^le']
  comment=comment.lower()
  for a in ecritures_bizarres:
    if a in comment:
      comment=comment.replace(a, 'grele')
  return(comment)
