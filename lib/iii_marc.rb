#!/usr/bin/env ruby
require 'enhanced_marc'
require 'htmlentities'
require 'iconv'
require 'httparty'
require 'nokogiri'
require 'uri'

require 'iii_marc/utils'
require 'iii_marc/constants'
require 'iii_marc/datafield'
require 'iii_marc/record'
require 'iii_marc/reader'