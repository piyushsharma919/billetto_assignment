
require "clerk"

Clerk.configure do |config|
  config.publishable_key = ENV.fetch("CLERK_PUBLISHABLE_KEY")
  config.secret_key = ENV.fetch("CLERK_SECRET_KEY")

  config.debug = Rails.env.development?
  config.logger = Rails.logger

  config.cache_store = Rails.cache
end
