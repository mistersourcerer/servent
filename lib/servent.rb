require "faraday"
require "servent/version"
require "servent/event_source"

module Servent
  COLON = "\u{003A}".freeze
  KNOWN_EVENTS = %w[event id retry data].freeze

  CONNECTING = 0
  OPEN       = 1
end
