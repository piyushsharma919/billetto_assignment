class ApplicationController < ActionController::Base
  include Clerk::Authenticatable
  include Pagy::Method

  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user

  private

  def current_user
    return unless clerk&.user?

    {
      clerk_user_id: clerk.user_id
    }
  end

  def authenticate_user!
    return if clerk&.user?

    redirect_to sign_in_path, alert: "Please sign in to continue."
  end
end
