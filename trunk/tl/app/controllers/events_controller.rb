class EventsController < ApplicationController
  def index
    @events = Event.find(:all, :order => "start")
  end

  def simile 
    @events = Event.find(:all, :order => "start")
    
    f = File.new("public/simile.gen.xml", "w")
    xml = Builder::XmlMarkup.new(:target => f, :indent => 1)
    xml.data do
      @events && @events.each { |event|
        if event.end.nil?
          # point events
          xml.event((event.description || "") +
             "<div class='edit-event' id='edit-event-#{event.id}'>[Edit]</div>",
             :start => event.start.strftime("%b %d %Y %H:%M:%S"), 
             :title => event.name)
        else
          # range events
          xml.event((event.description || "") +
             "<div class='edit-event' id='edit-event-#{event.id}'>[Edit]</div>",
             :start => event.start.strftime("%b %d %Y %H:%M:%S"), 
             :end => event.end.strftime("%b %d %Y %H:%M:%S"), 
             :title => event.name, 
             :isDuration => "true")
        end
      }
    end
    f.close

    @anchorDate, @intervalUnit1, @intervalUnit2 = simile_params(@events)
    render :layout => "simile"
  end

  def simile_params(events)
    # anchor date, interval units, interval pixels
    min_date = Event.minimum('start')
    max_date = Event.maximum('start')
    max_end = Event.maximum('end')
    if max_end && max_end > max_date
      max_date = max_end
    end

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

    return anchorDate, intervalUnit1, intervalUnit2
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
    @event = Event.new(params[:event])
    if @event.save
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
    @event = Event.find(params[:id])
    @event.destroy
    
    redirect_to :action => "index"
  end

end
