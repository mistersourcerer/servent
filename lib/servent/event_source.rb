require "servent/stream"
require "servent/event"

module Servent
  class EventSource
    def initialize(url, adapter: nil)
      # if adapter.nil?
      # call faraday and allow client to configure it (builder)
      @uri     = URI(url)
      @adapter = adapter
    end

    def start
      @adapter.get(@uri.path) do |req|
        req.headers["Accept"] = "text/event-stream"
      end
    end
  end
end
