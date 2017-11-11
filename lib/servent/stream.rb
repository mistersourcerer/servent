module Servent
  class Stream
    attr_reader :last_event_id

    def initialize(stream)
      @stream = StringIO.new stream
      @buffer = []
      @events = []
    end

    def parse
      @stream.each_line { |line|
        next if line.start_with?(Servent::COLON)
        handle_line line
      }
      complete_event
      @events
    end

    private

    def handle_line(line)
      # Line is empty:
      #  - can be the end of a stream or
      #  - can be a stream with multiple events
      if line.strip.chomp.empty?
        complete_event line
      else
        buffer line
      end
    end

    def complete_event(line = nil)
      return if @buffer.empty?

      buffer line unless line.nil?
      event = Event.new(@buffer.join("\n"))
      @events << event
      @last_event_id = event.id
      @buffer = []
    end

    def buffer(line)
      # TODO: if this line defines a new type, than also #complete_event
      @buffer << line
    end
  end
end
