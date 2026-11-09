class EventsController < ApplicationController
  def index
    @events = Event.order(starts_at: :asc)
  end
end
