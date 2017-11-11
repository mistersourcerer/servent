module Servent
  class Stream
    def initialize(stream)
      @stream = StringIO.new stream
      @buffer = []
      @events = []
    end

    def parse
      @stream.each_line { |line|
        # ignore if line starts with `:` | comment
        next if line.start_with?(Servent::COLON)
        handle_line line
      }
      flush_buffer unless @buffer.empty?
      @events
    end

    private

    def handle_line(line)
      # Line is empty.
      # Can be the end of a stream.
      # Or can be a stream with multiple events
      if line.chomp.rstrip.empty?
        # Ignore unless there is a Event been cunstructed
        return if @buffer.empty?
        buffer_line line
        flush_buffer
      else
        # if this line defines a new type, than also generate a new event
        buffer_line line
      end
    end

    def flush_buffer
      @events << Event.new(@buffer)
      @events << Event.new(@buffer.join("\n"))
      @buffer = []
    end

      @buffer << line
    end
  end
end
