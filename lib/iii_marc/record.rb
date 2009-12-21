module MARC
  class Record
    attr_accessor :bibnum, :raw, :record_url, :marc_url
    
    # Fixes the shorthand method for field lookup to 
    # correctly return an Array if field repeats
    def [](tag)
      return self.find_all {|f| f.tag == tag}      
    end
    
    # Extensions    
    def is_available_online
      has_link? ? true : false
    end
    
    # Fields   
    def access_restrictions
      self['506'].empty? ? "" : self['506'].collect { |field| field.value }.join("; ")
    end
    
    def author
      ['100','110','111'].each do |tag|
        return self[tag].collect{|field| field.value }.join(" ") unless self[tag].empty?
      end
      ""
    end
    
    def author_name
      ['100','110','111'].each do |tag|
        return self[tag][0]['a'] unless self[tag].empty?
      end
      ""
    end

    def author_dates
      ['100','110','111'].each do |tag|
        return self[tag][0]['d'] unless self[tag].empty?
      end
      ""
    end
    
    def other_authors
      ['700','710','711'].each do |tag|
        return self[tag].collect { |field| field.value } unless self[tag].empty?
      end
      ""
    end
    
    def call_number
      self['096'].empty? ? "" : self['096'][0].value
    end
    
    def comp_file_characteristics
      self['256'].empty? ? "" : self['256'][0].value
    end
    
    def contents
      self['505'].empty? ? [] : self['505'].collect { |field| field.value }.join(" ")
    end
    
    def edition
      self['250'].empty? ? "" : self['250'][0].value
    end
    
    def entry_preceding_is_union
      if self['780'].empty?
        false
      else
        self['780'][0].indicator2.eql?("4") ? true : false
      end
    end
    
    def entry_notes
      self['580'].empty? ? [] : self['580'].collect { |field| field.value }
    end
    
    def entries_preceding
      if self['780'].empty?                 
        []
      else
        self['780'].collect{ |field|           
          {
            :title => "#{field['a']} #{field['t']}".strip(), 
            :issn => field['x'], 
            :rel => PRECEEDING_ENTRY_LABELS[field.indicator2]
          }
        }
      end    
    end
    
    def entries_succeeding
      if self['785'].empty?                 
        []
      else
        self['785'].collect{ |field|           
          {
            :title => "#{field['a']} #{field['t']}".strip(), 
            :issn => field['x'], 
            :rel => SUCCEEDING_ENTRY_LABELS[field.indicator2]
          }
        }
      end
    end
    
    def links
      if has_link?
        self['856'].collect { |field| {:url => field['u'], :label => field['z'] } }
      else
        []
      end
    end
    
    def isbn
      if self['020'].nil?
        []
      else
        self['020'].collect{ |field| field['a'].match(/[\d-]+/) ? field['a'].match(/[\d-]+/)[0] : field['a'] }
      end
    end
    
    def issn
      if self['022'].nil?
        []
      else
        self['022'].collect{ |field| field['a'].match(/[\d-]+/) ? field['a'].match(/[\d-]+/)[0] : field['a'] }
      end
    end
    
    def notes
      ignore = [505,506,520,580,590] # 590 is a local notes field that isn't particularly relevant outside of III
      notes = []
      (500..599).each do |tag|
        next if ignore.include?(tag)
        notes << self[tag.to_s].collect { |field| field.value }.join("; ") unless self[tag.to_s].empty?
      end
      notes
    end
    
    def physical_description
      self['300'].empty? ? "" : self['300'].collect { |field| field.value }.join("; ")
    end
    
    def publishers
      self['260'].empty? ? [] : self['260'].collect { |field| field.value }
    end
    
    def pub_dates
      self['362'].empty? ? [] : self['362'].collect { |field| field.value }
    end
    
    def pub_frequency
      self['310'].empty? ? "" : self['310'][0].value
    end
    
    def former_pub_frequencies
      self['321'].empty? ? [] : self['321'].collect { |field| field.value }
    end
    
    def series
      return self['490'].collect { |field| field.value } unless self['490'].empty?
      self['440'].empty? ? [] : self['440'].collect { |field| field.value }
    end
    
    def series_main
      self['760'].empty? ? [] : self['760'].collect { |field| field.value }
    end
    
    def subjects
      if self['650'].empty?
        []
      else
        self['650'].collect { |field| field.subfields.map {|s| s.value} .join ' -- ' }
      end
    end
    
    def summary
      if self['520'].empty?
        ""
      else
        self['520'].collect { |field| field.value }.join(" ")
      end
    end
    
    def supplement
      self['770'].empty? ? [] : self['770'].collect { |field| field.value }
    end
    
    def supplement_parent
      self['772'].empty? ? [] : self['772'].collect { |field| field.value }
    end
    
    def title
      self['245'].empty? ? "" : self['245'][0].value
    end
    
    def title_varying_forms
      self['246'].empty? ? [] : self['246'].collect { |field| field.value }
    end
    
    def title_abbrv
      self['210'].empty? ? [] : self['210'].collect { |field| field.value }
    end
    
    def title_key
      self['222'].empty? ? [] : self['222'].collect { |field| field.value }
    end
    
    def title_uniform_related
      self['730'].empty? ? [] : self['730'].collect { |field| field.value }
    end
    
    def title_uniform
      self['130'].empty? ? "" : self['130'][0].value
    end
    
    def check_digit
        #Calculates the check digit from bib record number.
        #The algorithm to calculate check digits is found at the following URL:
        #http://csdirect.iii.com/manual/rmil_records_numbers.html
        return nil unless self.bibnum
        
        total = 0
        multiplier = 2
        self.bibnum[1..-1].reverse.split("").each do |num|
          num = num.to_i
          raise ArgumentError, "Something wrong with bibnum ...?" unless (0 <= num and num <= 9)
          num *= multiplier
          total += num
          multiplier += 1
        end
        dig = total % 11
        return dig != 10 ? dig.to_s : 'x'
    end
          
    # Quick-and-dirty field checks
    def has_link?
      !self['856'].empty?
    end
    
    def keywords      
      kw = []
      kw += author.split unless author.nil?
      kw << author_name unless author_name.nil?
      kw += title.split
      unless other_authors.nil?
        other_authors.each { |a| kw += a.split } 
      end
      kw << call_number unless call_number.nil?
      kw += contents.split unless contents.nil?
      unless entries_preceding.nil?
        entries_preceding.each do |e|
          kw += e[:title].split unless e[:title].nil?
          kw << e[:issn][0] unless e[:issn].nil?
        end 
      end
      unless entries_succeeding.nil?
        entries_succeeding.each do |e|
          kw += e[:title].split unless e[:title].nil?
          kw << e[:issn][0] unless e[:issn].nil?
        end 
      end
      isbn.each {|i| kw << i }
      issn.each {|i| kw << i }
      notes.each { |n| kw += n.split } unless notes.nil?
      publishers.each {|p| kw += p.split } unless publishers.nil?
      series.each {|s| kw += s.split } unless series.nil?
      series_main.each {|s| kw += s.split } unless series_main.nil?
      subjects.each do |s|
        kw << s
        kw += s.split(' -- ')
      end unless subjects.nil?
      kw += summary.split unless summary.nil?
      kw += title.split
      return kw.uniq.select{ |w| !KEYWORD_STOPWORDS.include?(w) }.collect{ |w| w.to_s.gsub(/[(,?!\'":.)]/, '') }.sort
    end
    
  end
end