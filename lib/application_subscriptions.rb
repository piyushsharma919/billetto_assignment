class ApplicationSubscriptions
  def self.register(event_store)
    new.handlers.each do |event_class, handler_classes|
      handler_classes.each do |handler|
        event_store.subscribe(handler.new, to: [ event_class ])
      end
    end
  end

  def handlers
    [
      Voting.subscriptions
    ].reduce(&:merge)
  end
end
