class Fact < RubyEventStore::Event
  class InvalidData < ArgumentError; end

  def self.strict(data:, **options)
    validate!(data)
    new(data: data, **options)
  end

  def self.validate!(data)
    schema = self::SCHEMA
    missing = schema.keys - data.keys
    unexpected = data.keys - schema.keys
    invalid = schema.reject { |key, type| !data.key?(key) || Array(type).any? { |t| data[key].is_a?(t) } }.keys

    problems = []
    problems << "missing: #{missing.join(', ')}" if missing.any?
    problems << "unexpected: #{unexpected.join(', ')}" if unexpected.any?
    problems << "invalid type: #{invalid.join(', ')}" if invalid.any?
    raise InvalidData, "#{name} #{problems.join('; ')}" if problems.any?
  end

  def stream_names
    raise NotImplementedError, "#{self.class} must define #stream_names"
  end

  def publish_to(event_store)
    main, *others = stream_names
    event_store.publish(self, stream_name: main)
    others.each { |stream| event_store.link(event_id, stream_name: stream) }
  end
end
