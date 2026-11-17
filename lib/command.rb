module Command
  class UnknownCommand < StandardError; end

  class Invalid < ArgumentError; end
end
