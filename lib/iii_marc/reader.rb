module MARC
  class IIIReader
    
    class ParserError < RuntimeError; end
    class NonExistentRecordError < RuntimeError; end
    
    include HTTParty
    
    attr_accessor :base_uri, :record_uri, :marc_uri
    attr_reader :coder
    
    def initialize(opac_uri)
      @entities = HTMLEntities.new      
      self.class.base_uri(opac_uri)
    end
    
    
    # Method for creating the appropriate MARC::Record 
    # based object by inspecting the record's leader
    def create_record_for_type(leader)
      leader = Leader.new(leader)
      if RECORD_TYPES.has_key?(leader.get_type)
        record = RECORD_TYPES[leader.get_type].new
      else
        record = MARC::Record.new
      end
      record.leader = leader
      record
    end
        
    def get_page(uri)
      resp = self.class.get(uri)
      if resp.code < 400
        resp.body
      else
        nil
      end
    end
      
    def record_exists?(bibnumber)
      page = get_page(URI_FOR_RECORD % bibnumber)
      return false unless page
      page.include?('No Such Record') ? false : true
    end
    
    # b1000000
    # b1069789
    def crawl_records(bib_start, bib_end)
      unless bib_start.starts_with('b') and bib_end.starts_with('b')
        raise ArgumentError, 'Invalid bib record number'
      end
      
      bib_start = bib_start[1..-1].to_i
      bib_end = bib_end[1..-1].to_i      
      records = Array.new
      
      (bib_start..bib_end).each do |num|
        record = get_record("b#{num}")
        if record and block_given?
          yield record
        else
          records << record if record
        end
      end
      return records unless block_given?
    end
    
    
    
    # Method for retrieving a record from the opac, decoding it 
    # and returning a MARC::Record object
    def get_record(bibnumber)
      if record_exists?(bibnumber)
        marc_url = URI_FOR_MARC % Array.new(3, bibnumber)
        record_url = URI_FOR_RECORD % bibnumber
        
        # Retrieve MARC data and convert to UTF-8 prior to decoding ...
        record_page = get_page(marc_url)
        record_data = MARC_REGEX.match(record_page)
        
        if record_data.nil?
          raise ParserError, "Could not decode data: MARC data not found."
        else
          record_data = record_data[1].strip()
          record_data = Iconv.conv('UTF-8','LATIN1',record_data)
        end

        record = decode_raw(record_data)
        unless record.nil?
          record.bibnum = bibnumber
          record.raw = record_data
          record.record_url = "#{self.class.base_uri}#{record_url}"
          record.marc_url = "#{self.class.base_uri}#{marc_url}"
        end
        return record
      else
        raise NonExistentRecordError, "Record not found."
      end
    rescue NonExistentRecordError => error
      warn error.message
      return nil
    rescue ParserError => error  
      warn error.message
      return nil
    end
    
    
    # Method for turning pseudo MARC data from III's OPAC 
    # into a MARC::Record object.
    # ---
    # Only data conversion done is replacing HTML entities with their 
    # corresponding characters
    def decode_raw(pseudo_marc)
      raise ParserError, "Cannot decode empty string." if pseudo_marc == ""
      
      pseudo_marc = pseudo_marc.split("\n")      
      raw_fields = []
      
      if pseudo_marc[0][0..5] == "LEADER"
        record = create_record_for_type(pseudo_marc[0][7..-1])
      else
        raise ParserError, "Cannot decode record without a leader."
      end
            
      pseudo_marc[1..pseudo_marc.length].each do |field|
        data = @entities.decode(field[7..-1])
        if field[0..2] != '   '
          data = MARC::ControlField.control_tag?(field[0..2]) ? data : "a#{data}"
          raw_fields << { 
            :tag => field[0..2], 
            :indicator1 => field[4,1], 
            :indicator2 => field[5,1], 
            :value => data.strip, 
            :raw => field.strip
          }
        else          
          raw_fields.last[:value] += " #{data}"
          raw_fields.last[:raw] += field.strip
        end
      end
      
      raw_fields.each do |field|
        tag = field[:tag]
        field_data = field[:value]
        if MARC::ControlField.control_tag?(tag)
          record.append(MARC::ControlField.new(tag, field_data))          
        else
          datafield = MARC::DataField.new(tag)
          datafield.indicator1 = field[:indicator1]
          datafield.indicator2 = field[:indicator2]
          
          field_data.split('|').each{|sub| 
            subfield = MARC::Subfield.new(sub[0,1], sub[1..-1])
            datafield.append(subfield)
          }
          record.append(datafield)
        end
      end
      
      return record
    end
    
  end  
end
