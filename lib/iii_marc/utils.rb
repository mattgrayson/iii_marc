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
  
  def strip_start_punctuation   
    punc = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
    str = self.strip()
    if punc.include?(str[0...1])
      str[1...str.length]
    else
      self
    end
  end
  
  def strip_punctuation
    str = self.strip()
    str = str.strip_start_punctuation unless str == ''
    str = str.strip_end_punctuation unless str == ''
    str
  end
end