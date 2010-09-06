require 'builder'

class EventsController < ApplicationController

  def index
    @events = Event.find(:all, :order => "start")
  end

  def simile 
    # retrieve events to display
    @events = get_events(params[:move])

    # generate xml file for events
    f = File.new("public/simile.gen.xml", "w")
    xml = Builder::XmlMarkup.new(:target => f, :indent => 1)
    xml.data do
      @events && @events.each { |event|
        if event.end.nil?
          # point events
          xml.event((event.description || "") +
             "<div class='delete-event' id='delete-event-#{event.id}'>[Delete]</div>
             <div class='edit-event' id='edit-event-#{event.id}'>[Edit]</div>",
             :start => event.start.strftime("%b %d %Y %H:%M:%S"), 
             :title => event.name)
        else
          # range events
          xml.event((event.description || "") +
             "<div class='delete-event' id='delete-event-#{event.id}'>[Delete]</div>
             <div class='edit-event' id='edit-event-#{event.id}'>[Edit]</div>",
             :start => event.start.strftime("%b %d %Y %H:%M:%S"), 
             :end => event.end.strftime("%b %d %Y %H:%M:%S"), 
             :title => event.name, 
             :isDuration => "true")
        end
      }
    end
    f.close

    # render timeline
    render :layout => "simile"
  end

  def get_events(move)
    events = nil
    intervalUnit1 = nil
    multiple1 = nil
    intervalUnit2 = nil
    multiple2 = nil
    anchorDate = nil

    # get new date range
    abs_min_date = Event.minimum("start")
    abs_max_date = [Event.maximum("start"), Event.maximum("end")].max
    if session[:max_date] && session[:min_date] && move
      min_date = session[:min_date]
      max_date = session[:max_date]
      range = session[:max_date] - session[:min_date]
      range = 24*60*60 if range == 0 # 1 day if 0
      case move
      when "in"
        if range > 24*60*60
          new_daysrange, intervalUnit1, multiple1 = SimileInterval.get_smaller_interval(
                      session[:interval_unit1], session[:multiple1])
          range_diff = (range - (new_daysrange*24*60*60))/2
          min_date = session[:min_date] + range_diff
          max_date = session[:max_date] - range_diff
        end
      when "out"
        if session[:min_date] > abs_min_date || session[:max_date] < abs_max_date
          new_daysrange, intervalUnit1, multiple1 = SimileInterval.get_larger_interval(
                      session[:interval_unit1], session[:multiple1])
          range_diff = (new_daysrange*24*60*60 - range)/2
          min_date = session[:min_date] - range_diff
          max_date = session[:max_date] + range_diff
        end
      when "left"
        if session[:min_date] > abs_min_date 
          max_date = session[:max_date] - range/2
          min_date = session[:min_date] - range/2
        end
      when "right"
        if session[:max_date] < abs_max_date
          min_date = session[:min_date] + range/2
          max_date = session[:max_date] + range/2
        end
      end
    else
      min_date = abs_min_date
      max_date = abs_max_date
    end

    # get events for the date range
    events = Event.get(min_date, max_date)

    # set anchor date as the mid-point of date range
    anchorDate = min_date + (max_date - min_date)/2

    # set interval units for the date range
    if intervalUnit1.nil?
      days_range = (max_date - min_date)/(24*60*60)
      intervalUnit1, multiple1 = SimileInterval.map_range_to_interval(days_range)
    end
    intervalUnit2, multiple2 = intervalUnit1, multiple1*5

    # store in session
    session[:min_date] = min_date
    session[:max_date] = max_date
    session[:anchor_date] = anchorDate
    session[:interval_unit1] = intervalUnit1
    session[:multiple1] = multiple1
    session[:interval_unit2] = intervalUnit2
    session[:multiple2] = multiple2

    return events
  end

  def show
  end

  def new
    @event = Event.new
    render :layout => "simile"
  end

  def get
    @event = Event.find(params[:id])
    render :json => @event.to_json
  end
  
  def create
    # TBD: Verify params
    
    @event = Event.new(params[:event])
    flash[:notice] = "Event created successfully!"
    if @event.save
      respond_to do |format|
        format.html { redirect_to :action => "simile" }
        format.js
      end
    end
  end

  def update
    @event = Event.find(params[:event][:id])
    flash[:notice] = "Event updated successfully!"
    if @event.update_attributes(params[:event])
      respond_to do |format|
        format.html { redirect_to :action => "simile" }
        format.js
      end
    end
  end

  def destroy
    @event = Event.find(params[:event][:id])
    @event.destroy
    
    redirect_to :action => "simile"
  end

end
