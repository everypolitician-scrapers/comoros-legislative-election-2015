#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  trs = noko.xpath('//h3[span[@id="Elected_MPs"]]/following-sibling::table[1]//tr[td]')
  abort "No members" if trs.count.zero?

  trs.each do |tr|
    tds = tr.css('td')
    data = { 
      name: tds[1].text.tidy,
      wikiname: tds[1].xpath('.//a[not(@class="new")]/@title').text,

      area: tds[0].text.tidy,

      party: tds[2].text.tidy,
      party_wikiname: tds[2].xpath('.//a[not(@class="new")]/@title').text,
    }
    ScraperWiki.save_sqlite([:name, :area, :party], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/Comorian_legislative_election,_2015')
