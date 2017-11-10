module Servent
  class Event
    attr_reader :type, :data

    def initialize
      @data = ""
    end

    def parse(stream)
      StringIO.open(stream) do |io|
        io.each_line { |line| parse_line line }
      end
    end

    private

    def parse_line(line)
      # empty line?, nothing -> ignore
      return if line.chomp.rstrip.empty?

      # starts with :, comment -> ignore

      # contains :, field -> split : field => data (remove first space)
      return parse_field line if line.include?("\u{003A}") # include? ":"

      # else, field: field = data, data = ''
    end

    def parse_field(line)
      field = Field.new(* line.split(":"))
      @type = field.type
      @data << "\n" unless @data.empty?
      @data << field.data
    end
  end

  class Field
    attr_reader :type

    def initialize(type, raw_data)
      @type = type
      @raw_data = raw_data.chomp
    end

    def data
      @data ||= if @raw_data[0] == "\u{0020}"
                  # remove first char if it is a space.
                  @raw_data[1..(@raw_data.length - 1)]
                else
                  @raw_data
                end
    end
  end
end
