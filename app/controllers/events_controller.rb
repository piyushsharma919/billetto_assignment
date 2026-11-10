class EventsController < ApplicationController
  def index
    @events = Event.includes(:event_vote_count).order(starts_at: :asc)
  end
end
