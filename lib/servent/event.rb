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

    COLON = "\u{003A}".freeze

    def parse_line(line)
      return unless line.include?(COLON)

      @type, data = line.split(":")
      @data << "\n" unless @data.empty?
      @data << remove_extra_space(data)
      #if type != @type; # new event?
    end

    def remove_extra_space(raw_data)
      return raw_data unless raw_data[0] == "\u{0020}"

      raw_data[1..(raw_data.length - 1)]
    end
  end
end
