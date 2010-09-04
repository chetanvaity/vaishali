require 'builder'

class EventsController < ApplicationController
  def index
    @events = Event.find(:all, :order => "start")
  end

  def simile 
    @events, min_date, max_date = get_events(params[:move], 10) 

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

    simile_params(@events, min_date, max_date)
    render :layout => "simile"
  end

  def get_events(move, zoomfactor)
    events = nil
    min_date = nil
    max_date = nil
    if session[:max_date] && session[:min_date]
      range = session[:max_date] - session[:min_date]
      range = 365*24*60*60 if range == 0 # 1 year if 0
      case move
      when "in"
        range_diff = (range - range/zoomfactor)/2
        min_date = session[:min_date] + range_diff
        max_date = session[:max_date] - range_diff
      when "out"
        range_diff = (range*zoomfactor - range)/2
        min_date = session[:min_date] - range_diff
        max_date = session[:max_date] + range_diff
      when "left"
        max_date = session[:min_date]
        min_date = session[:min_date] - range
      when "right"
        min_date = session[:max_date]
        max_date = session[:max_date] + range
      end
    end
    p ">>>>>> min date", min_date
    p ">>>>>> max date", max_date
    events = Event.get(min_date, max_date)
    return events, min_date, max_date
  end

  def simile_params(events, min_date, max_date)
    # anchor date, interval units, interval pixels
    n = events.size
    min_date = min_date || events[0][:start]
    max_date = max_date || events[n-1][:end] || events[n-1][:start]

    anchorDate = min_date
    days_range = (max_date - min_date)/(24*60*60)
    if days_range > 36500
      intervalUnit1 = "DECADE"
      intervalUnit2 = "CENTURY"
    elsif days_range > 365
      intervalUnit1 = "YEAR"
      intervalUnit2 = "DECADE"
    else
      intervalUnit1 = "DAY"
      intervalUnit2 = "YEAR"
    end

    session[:anchor_date] = anchorDate
    session[:interval_unit1] = intervalUnit1
    session[:interval_unit2] = intervalUnit2
    session[:min_date] = min_date
    session[:max_date] = max_date
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
    # Verify params
    
    @event = Event.new(params[:event])
    if @event.save
      redirect_to :action => "simile"
    else
      redirect_to :action => "simile"
    end
  end

  def update
    @event = Event.find(params[:event][:id])
    if @event.update_attributes(params[:event])
      redirect_to :action => "simile"
    end
  end

  def destroy
    @event = Event.find(params[:event][:id])
    @event.destroy
    
    redirect_to :action => "simile"
  end

end
