class EventsController < ApplicationController
  def index
    @pagy, @events = pagy(
      Event.includes(:event_vote_count).order(starts_at: :asc),
      limit: 12
    )
  end
end
