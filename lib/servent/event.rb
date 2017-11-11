module Servent
  class Event
    attr_reader :type, :id

    def initialize(event)
      @data = []
      StringIO.open(event) do |io|
        io.each_line { |line| parse_line line }
      end
    end

    def data
      @_data ||= @data.join("\n")
    end

    private

    def parse_line(line)
      return unless line.include?(Servent::COLON)
      field_name, data = line.split(":")
      normalized_data = remove_first_space(data).chomp
      process_as_field field_name, normalized_data
    end

    def process_as_field(field_name, data)
      return unless KNOWN_EVENTS.include?(field_name)
      field_handler = method("field_#{field_name}")
      field_handler.call data
    end

    def remove_first_space(string)
      return string unless string[0] == "\u{0020}"
      string[1..(string.length - 1)]
    end

    def field_event(data)
      @type = data
    end

    def field_id(data)
      @id = data
    end


    def field_data(data)
      @type = "message" if @type.nil?
      @data << data
    end
  end
end
