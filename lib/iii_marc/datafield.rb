module MARC
  class DataField
  
    # Slight alteration from original to include a space between 
    # subfields instead of the default ''.
    def value
      return(@subfields.map {|s| s.value} .join ' ')
    end
    
  end
end