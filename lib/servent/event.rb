module Servent
  class Event
    attr_reader :type, :data

    def initialize(event)
      @data = ""
      StringIO.open(event) do |io|
        io.each_line { |line| parse_line line }
      end
    end

    private

    def parse_line(line)
      return unless line.include?(Servent::COLON)
      normalize_type_and_data(* line.split(":"))
    end

    def normalize_type_and_data(type, data)
      if type == "event"
        @type = remove_extra_space data.chomp
      else
        @type = "message" if @type.nil?
        concat_data data
      end
    end

    def remove_extra_space(raw_data)
      return raw_data unless raw_data[0] == "\u{0020}"
      raw_data[1..(raw_data.length - 1)]
    end

    def concat_data(data)
      @data << "\n" unless @data.empty?
      @data << remove_extra_space(data).chomp
    end
  end
end
