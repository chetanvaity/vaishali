require 'net/http'
require 'uri'

class Event < ActiveRecord::Base
  validates_presence_of :name, :start

  def self.get(min_date, max_date)
    if min_date && max_date
      Event.find(:all, :conditions => [ "start >= ? and start <= ? and (end is null or end <= ?)", min_date, max_date, max_date ], :order => "importance desc", :limit => 100)
    else
      Event.find(:all, :order => "importance desc", :limit => 100)
    end
  end

  def search_volume
    out = nil
    begin
      phrase = '"' + name + '"'
      url = URI.parse("http://www.google.co.in/search?q=#{CGI.escape(phrase)}")
      res = Net::HTTP.get url
      unless res.nil?
        results = res.match("<div id=resultStats>About (.*) results")
        if !results.nil?
          out = results[1].gsub(",","").to_i
        elsif !res.match("No results found for <b>&quot;#{name}&quot;</b>").nil?
          out = 0
        end
      end
    rescue => e
      raise "Error while trying to get search volume for event: #{name}: #{e}"
    end
    return out
  end
end
