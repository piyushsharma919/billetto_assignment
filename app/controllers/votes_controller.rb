
class VotesController < ApplicationController
  before_action :authenticate_user!

  def create
    event = Event.find(params[:event_id])

    Voting::CastVote.new(
      event: event,
      clerk_user_id: current_user[:clerk_user_id],
      vote_type: params[:vote_type]
    ).call

    redirect_back(
      fallback_location: root_path,
      notice: "Your vote has been recorded."
    )
  rescue ActiveRecord::RecordNotFound
    redirect_back(
      fallback_location: root_path,
      alert: "Event not found."
    )
  rescue ArgumentError => e
    redirect_back(
      fallback_location: root_path,
      alert: e.message
    )
  end
end
