module Handler
  extend ActiveSupport::Concern

  class_methods do
    def subscribes_to(*event_classes)
      @subscribed_to = event_classes
    end

    def subscriptions
      (@subscribed_to || []).index_with { [ self ] }
    end
  end
end
