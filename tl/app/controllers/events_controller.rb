class EventsController < ApplicationController
  def index
    @events = Event.find(:all, :order => "start")
  end

  def tl
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
          xml.event(event.description || "", 
                     :start => event.start.strftime("%b %d %Y %H:%M:%S"), 
                     :title => event.name)
        else
          # range events
          xml.event(event.description || "", 
                     :start => event.start.strftime("%b %d %Y %H:%M:%S"), 
                     :end => event.end.strftime("%b %d %Y %H:%M:%S"), 
                     :title => event.name, 
                     :isDuration => "true")
        end
        
      }
    end
    f.close
    render :layout => "simile"
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    
    redirect_to :action => "index"
  end

end
