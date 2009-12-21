# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{iii_marc}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Grayson"]
  s.date = %q{2009-12-21}
  s.description = %q{Utilities for interacting with III Millennium WebPac.  Primary goal is to retrieve and parse bibliographic records via the  WebPac proto-MARC output.}
  s.email = %q{mattgrayson@eitheror.org}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/iii_marc.rb",
     "lib/iii_marc/constants.rb",
     "lib/iii_marc/datafield.rb",
     "lib/iii_marc/reader.rb",
     "lib/iii_marc/record.rb",
     "lib/iii_marc/utils.rb",
     "test/helper.rb",
     "test/test_iii_marc.rb"
  ]
  s.homepage = %q{http://github.com/mattgrayson/iii_marc}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Utilities for interacting with III Millennium WebPac.  Primary goal is to retrieve and parse bibliographic records via the  WebPac proto-MARC output.}
  s.test_files = [
    "test/helper.rb",
     "test/test_iii_marc.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_runtime_dependency(%q<enhanced_marc>, [">= 0"])
      s.add_runtime_dependency(%q<htmlentities>, [">= 0"])
      s.add_runtime_dependency(%q<patron>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<enhanced_marc>, [">= 0"])
      s.add_dependency(%q<htmlentities>, [">= 0"])
      s.add_dependency(%q<patron>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<enhanced_marc>, [">= 0"])
    s.add_dependency(%q<htmlentities>, [">= 0"])
    s.add_dependency(%q<patron>, [">= 0"])
  end
end
