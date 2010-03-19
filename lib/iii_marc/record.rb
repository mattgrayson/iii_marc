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
      if !self['096'].empty?
        self['096'][0].value
      elsif !self['060'].empty?
        self['060'][0].value
      else
        ""
      end
    end
    
    def comp_file_characteristics
      self['256'].empty? ? "" : self['256'][0].value
    end
    
    def contents
      self['505'].empty? ? [] : self['505'].collect { |field| field.value }.join(" ")
    end
    
    def date_published
      if !self['260'].empty? and !self['260'][0]['c'].nil?
        puts self['260'][0]['c']
        self['260'][0]['c'].strip_end_punctuation
      elsif !self['096'].empty? and !self['096'][0]['c'].nil?
        self['096'][0]['c'].strip_end_punctuation
      else
        ""
      end
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
    
    def kind
      self.leader.record_type
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
      self['260'].empty? ? [] : self['260'].collect { |field| field.value.strip_end_punctuation }
    end
    
    def publisher_names
      if self['260'].empty? or self['260'][0]['b'].nil?
        []
      else
        self['260'].collect { |field| field['b'].strip_end_punctuation }
      end
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
    
    def statement_of_responsibility
      unless self['245'].empty? or self['245'][0]['c'].nil?
        self['245'][0]['c'].strip_end_punctuation
      else
        ""
      end
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
      if self['245'].empty?
        title = ""
      else 
        title = self['245'][0]['a'].nil? ? '' : self['245'][0]['a']
        title = "#{t} #{self['245'][0]['b']}" unless self['245'][0]['b'].nil?
        title = "#{t} #{self['245'][0]['p']}" unless self['245'][0]['p'].nil?
      end
      title.strip_end_punctuation
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
    
    
    def debug_output
      puts '*'*60
      puts "Bib #: #{self.bibnum}"
      puts "Check digit: #{self.check_digit}"
      puts "Call #: #{self.call_number}"
      puts "Record URL: #{self.record_url}"
      puts "MARC URL: #{self.marc_url}"
      puts "Type: #{self.kind}"
      
      puts '-'*60
      
      puts "Title: #{self.title}"
      puts "Statement of Responsibility: #{self.statement_of_responsibility}"
      puts "ISSN(s): #{self.issn.join(', ')}" if self.issn
      puts "ISBN(s): #{self.isbn.join(', ')}" if self.isbn
      puts "Publisher(s): #{self.publishers.join(', ')}"
      puts "Publisher name(s): #{self.publisher_names.join(', ')}"
      puts "Date publised: #{self.date_published}"
      puts "URLs:"
      self.links.each do |l|
        puts "- #{l[:label]}: #{l[:url]}"
      end
      puts "Author: #{self.author}"
      puts "Author dates: #{self.author_dates}"
      puts "Other authors: "
      self.other_authors.each do |a|
        puts "- #{a}"
      end
      
      puts '-'*60
      
      puts "Uniform title: #{self.title_uniform}"
      puts "Abbreviated title(s): #{self.title_abbrv.join(', ')}"
      puts "Key title(s): #{self.title_key.join(', ')}"
      puts "Varying form(s) of title: #{self.title_varying_forms.join(', ')}"
      
      puts "Edition: #{self.edition}"
      puts "Computer file characteristics: #{self.comp_file_characteristics}"
      puts "Physical description: #{self.physical_description}"
      
      puts "Publication frequency: #{self.pub_frequency}"
      puts "Former publication frequencies: #{self.former_pub_frequencies.join('; ')}"
      puts "Publication dates: #{self.pub_dates.join('; ')}"
      puts "Series: #{self.series.join('; ')}"
      
      puts '-'*60
      
      puts "Notes: "
      self.notes.each do |n|
        puts " - #{n}"
      end
       
      puts "Summary: #{self.summary}"
      puts "Contents: #{self.contents}"
      puts "Subjects: "
      self.subjects.each do |s|
        puts " - #{s}"
      end

      puts "Preceding titles: "
      self.entries_preceding.each do |ep|
        puts " - #{ep['title']}"
      end
      
      puts "Succeeding titles: "
      self.entries_succeeding.each do |es|
        puts " - #{es['title']}"
      end
      
      puts "Entry notes:"
      self.entry_notes.each do |en|
        puts " - #{en}"
      end
      
      puts '-'*60
      puts self.class
      puts '*'*60
    end    
  end
end