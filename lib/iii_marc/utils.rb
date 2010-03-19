# Just some convenience methods
class String
  def ends_with(characters)
    self[-characters.length...self.length] == characters ? true : false
  end
  
  def starts_with(characters)
    self[0...characters.length] == characters ? true : false
  end
  
  def strip_end_punctuation   
    punc = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
    str = self.strip()
    if punc.include?(str[str.length-1...str.length])
      str[0...str.length-1]
    else
      self
    end
  end
end