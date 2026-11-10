class EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = Event.order(starts_at: :asc)
  end
end
