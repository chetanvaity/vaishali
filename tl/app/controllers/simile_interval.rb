class SimileInterval < ApplicationController
  @@days_to_interval_map = [
    { :days => 1, :intervalUnit => "DAY", :multiple => 1 }, # 1 day
    { :days => 7, :intervalUnit => "WEEK", :multiple => 1 }, # 1 day
    { :days => 30, :intervalUnit => "MONTH", :multiple => 1 }, # 1 month
    { :days => 90, :intervalUnit => "MONTH", :multiple => 3 }, # quarter year
    { :days => 365, :intervalUnit => "YEAR", :multiple => 1 }, # 1 year
    { :days => 1825, :intervalUnit => "YEAR", :multiple => 5 }, # 5 years
    { :days => 3650, :intervalUnit => "YEAR", :multiple => 10 }, # 10 years
    { :days => 73000, :intervalUnit => "YEAR", :multiple => 20 }, # 20 years
    { :days => 18250, :intervalUnit => "YEAR", :multiple => 50 }, # half-century
    { :days => 36500, :intervalUnit => "CENTURY", :multiple => 1 }, # 1 century
    { :days => 182500, :intervalUnit => "CENTURY", :multiple => 5 }, # 5 centuries
    { :days => 365000, :intervalUnit => "CENTURY", :multiple => 10 }, # 10 centuries
    { :days => 1825000, :intervalUnit => "CENTURY", :multiple => 50 } # 50 centuries
  ]
  @@numblocks = 15

  def self.map_range_to_interval(days_range)
    idays = days_range/@@numblocks
    intervalUnit, multiple = nil, nil
    min_days = nil
    @@days_to_interval_map.each { |d|
      if (min_days.nil? or idays > min_days) and (idays <= d[:days])
        intervalUnit = d[:intervalUnit]
        multiple = d[:multiple]
        break
      else
        min_days = d[:days]
      end
    }
    return intervalUnit, multiple
  end

  def self.map_interval_to_range(intervalUnit, multiple)
    days_range = nil
    @@days_to_interval_map.each { |d|
      if d[:intervalUnit].eql?(intervalUnit) && d[:multiple].eql?(multiple)
        days_range = d[:days]*@@numblocks
        break
      end
    }
    return days_range
  end

  def self.get_smaller_interval(intervalUnit, multiple)
    out = nil
    @@days_to_interval_map.each { |d|
      if d[:intervalUnit].eql?(intervalUnit) && d[:multiple].eql?(multiple)
        out = d if out.nil?
        break
      else
        out = d
      end
    }
    return out[:days]*@@numblocks, out[:intervalUnit], out[:multiple]
  end

  def self.get_larger_interval(intervalUnit, multiple)
    out = nil
    found = false
    @@days_to_interval_map.each { |d|
      if found
        out = d
        break
      elsif d[:intervalUnit].eql?(intervalUnit) && d[:multiple].eql?(multiple)
        found = true
      end
    }
    return out[:days]*@@numblocks, out[:intervalUnit], out[:multiple]
  end
end
