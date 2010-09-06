class Event < ActiveRecord::Base
  validates_presence_of :name, :start

  def self.get(min_date, max_date)
    if min_date && max_date
      Event.find(:all, :conditions => [ "start >= ? and start <= ? and (end is null or end <= ?)", min_date, max_date, max_date ], :order => "start")
    else
      Event.find(:all, :order => "start")
    end
  end
end
