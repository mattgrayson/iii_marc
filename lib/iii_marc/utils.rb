# Just some convenience methods
class String
  def ends_with(characters)
    self[-characters.length...self.length] == characters ? true : false
  end
  
  def starts_with(characters)
      self[0...characters.length] == characters ? true : false
  end
end