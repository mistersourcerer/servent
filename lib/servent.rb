require "servent/version"
require "servent/event_source"

module Servent
  COLON = "\u{003A}".freeze
  KNOWN_EVENTS = ["event", "id", "retry", "data"].freeze
end
