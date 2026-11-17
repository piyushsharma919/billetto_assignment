namespace :billetto do
  desc "Fetch and import all public events from Billetto"
  task fetch_all_public_events: :environment do
    puts "Starting Import of all Billetto event ingestion"

    result = Domains::Billetto::PublicEvents.new.all_event

    puts "Import completed - created: #{result[:created]}, updated: #{result[:updated]}, errors: #{result[:errors]}"
  rescue Domains::Billetto::Error => e
    puts "Import failed: #{e.message}"
  end
end
