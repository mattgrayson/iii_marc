require 'helper'

class TestMarcIIIReader < Test::Unit::TestCase
  context "A reader instance should" do
    
    setup do
      base_uri = 'http://opac.fake'
      base_dir = File.dirname(__FILE__)      
      @reader = MARC::IIIReader.new('http://opac.fake', 2)
      
      # Non-existent record      
      FakeWeb.register_uri(:get, "#{base_uri}/record=b1069560~S2", :body => 'No Such Record')      
      # 404 URI
      FakeWeb.register_uri(:get, "#{base_uri}/record=b1069561~S2", :status => ["404", "Not Found"])
      # Existing records, but with unparsable data      
      FakeWeb.register_uri(:get, "#{base_uri}/record=b1052826~S2", :body => '...')
      FakeWeb.register_uri(:get, 
        "#{base_uri}/search~S2/.b1052826/.b1052826/1%2C1%2C1%2CB/marc~b1052826", 
        :body => File.open(File.join(base_dir,'/pages/marc_b1052826.html')).read()
      )
      FakeWeb.register_uri(:get, "#{base_uri}/record=b1069570~S2", :body => '...')
      FakeWeb.register_uri(:get, 
        "#{base_uri}/search~S2/.b1069570/.b1069570/1%2C1%2C1%2CB/marc~b1069570", 
        :body => File.open(File.join(base_dir,'/pages/marc_b1069570.html')).read()
      )
      FakeWeb.register_uri(:get, "#{base_uri}/record=b1069571~S2", :body => '...')
      FakeWeb.register_uri(:get, 
        "#{base_uri}/search~S2/.b1069571/.b1069571/1%2C1%2C1%2CB/marc~b1069571", 
        :body => File.open(File.join(base_dir,'/pages/marc_b1069571.html')).read()
      )
      # Existing, working record data
      FakeWeb.register_uri(:get, "#{base_uri}/record=b1069580~S2", :body => '...')
      FakeWeb.register_uri(:get, 
        "#{base_uri}/search~S2/.b1069580/.b1069580/1%2C1%2C1%2CB/marc~b1069580", 
        :body => File.open(File.join(base_dir,'/pages/marc_b1069580.html')).read()
      )
    end
    
    should "find correct record" do
      assert_equal @reader.get_record('b1069566').bibnum, "b1069566"
    end

    should "return nil for non-existent record" do
      assert_equal @reader.get_record('b1069560'), nil
    end
    
    should "return nil when data isn't parsable (i.e. missing or incomplete)" do
      assert_equal @reader.get_record('b1069570'), nil
      assert_equal @reader.get_record('b1069571'), nil
    end
    
    should "return nil when MARC data is missing LEADER" do
      assert_equal @reader.get_record('b1052826'), nil
    end
    
    should "return nil when 404 error is encountered" do
      assert_equal @reader.get_record('b1069561'), nil
    end
     
    should "return correct record type" do
      assert_equal @reader.get_record('b1069566').class.to_s, "MARC::SerialRecord"
    end
    
  end
  
  
  context "A parsed record should" do
    
    setup do
      base_uri = 'http://opac.fake'
      base_dir = File.dirname(__FILE__)      
      @reader = MARC::IIIReader.new('http://opac.fake', 2)

      FakeWeb.register_uri(:get, "#{base_uri}/record=b1069566~S2", :body => '...')
      FakeWeb.register_uri(:get, 
        "#{base_uri}/search~S2/.b1069566/.b1069566/1%2C1%2C1%2CB/marc~b1069566", 
        :body => File.open(File.join(base_dir,'/pages/marc_b1069566.html')).read()
      )
    end
    
    # Record tests    
    should "extract title correctly" do
      assert_equal @reader.get_record('b1069566').title, "The Backletter"
    end
    
  end
  
  
  context "A keyword search should" do
    
    setup do
      base_uri = 'http://opac.fake'
      base_dir = File.dirname(__FILE__)      
      @reader = MARC::IIIReader.new('http://opac.fake', 2)
            
      FakeWeb.register_uri(:get, 
        "#{base_uri}/search~S2/?searchtype=X&searcharg=cancer", 
        :body => File.open(File.join(base_dir,'/pages/search_keyword_cancer.html')).read()
      )
      
      FakeWeb.register_uri(:get, 
        "#{base_uri}/search~S2/?searchtype=X&searcharg=organicchemistryorganicchemistryorganicchemistry", 
        :body => File.open(File.join(base_dir,'/pages/search_keyword_no_results.html')).read()
      )
    end
    
    should "return parsed search results array" do
      assert_equal @reader.keyword_search('cancer').class, Array
    end
    
    should "return all results" do
      assert_equal @reader.keyword_search('cancer').count, 50
    end
    
    should "cleanly handle searches with no results" do
      results = @reader.keyword_search('organicchemistryorganicchemistryorganicchemistry')
      assert_equal results.count, 0
    end
    
    should "extract the title for each result" do
      results = @reader.keyword_search('cancer')
      assert_not_equal results, []
      
      results.each do |r|
        assert_not_nil r[:title]
        assert_not_equal r[:title], ""
      end
      assert_equal results.collect{ |r| r[:title] }.count, 50
    end
    
    should "extract bibnum for each result" do
      results = @reader.keyword_search('cancer')
      assert_not_equal results, []
      
      results.each do |r|
        assert_not_nil r[:bibnum]
        assert_not_equal r[:bibnum], ""
      end
    end
    
    should "extract year for each result" do
      results = @reader.keyword_search('cancer')
      assert_not_equal results, []
      
      results.each do |r|
        assert_not_nil r[:year]
        assert_not_equal r[:year], ""
      end
    end
    
  end
  
  
  context "A title search should" do
    
    setup do
      base_uri = 'http://opac.fake'
      base_dir = File.dirname(__FILE__)      
      @reader = MARC::IIIReader.new('http://opac.fake', 2)
      
      FakeWeb.register_uri(:get, 
        "#{base_uri}/search~S2/?searchtype=t&searcharg=organic%20chemistry", 
        :body => File.open(File.join(base_dir,'/pages/search_title_organic_chemistry.html')).read()
      )
    end
    
    should "return parsed search results array" do
      assert_equal @reader.title_search('organic chemistry').class, Array
    end
    
    should "extract the title for each result" do
      results = @reader.title_search('organic chemistry')
      assert_not_equal results, []
      
      results.each do |r|
        assert_not_nil r[:title]
        assert_not_equal r[:title], ""
      end
      assert_equal results.collect{ |r| r[:title] }.count, 35
    end
    
    should "extract author information for each result where possible" do
      results = @reader.title_search('organic chemistry')
      assert_not_equal results, []
      
      results.each do |r|
        assert_not_nil r[:author]
      end
      assert_equal results.select{ |r| r[:author] != '' }.count, 27
    end
    
    should "extract call number for each result where possible" do
      results = @reader.title_search('organic chemistry')
      assert_not_equal results, []
      
      results.each do |r|
        puts r[:title]
        puts r[:author]
        puts r[:call_number]
        puts '0'*50
        assert_not_nil r[:call_number]
      end
      assert_equal 31, results.select{ |r| r[:call_number] != '' }.count
    end
    
    should "extract total items for each result" do
      results = @reader.title_search('organic chemistry')
      assert_not_equal results, []
      
      results.each do |r|
        assert_not_nil r[:items]
        assert_not_equal r[:items], ""
      end
    end
    
    should "return all results" do
      assert_equal @reader.title_search('organic chemistry').count, 35
    end 
    
  end
  
  
  
end