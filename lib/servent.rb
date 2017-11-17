require "servent/version"
require "servent/event_source"

module Servent
  COLON = "\u{003A}".freeze
  KNOWN_EVENTS = %w[event id retry data].freeze

  CONNECTING = 0
  OPEN       = 1
  CLOSED     = 2

  REDIRECT_STATUSES      = [301, 302, 303, 307]
  RECONNECTION_STATUSES  = [500, 502, 503, 504]
  AUTHORIZATION_STATUSES = [305, 401, 407]

  KNOWN_STATUSES = [200]  +
    REDIRECT_STATUSES     +
    RECONNECTION_STATUSES +
    AUTHORIZATION_STATUSES
end
