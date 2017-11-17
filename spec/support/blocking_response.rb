class BlockingResponse
  def initialize
    @r, @w = IO.pipe
  end

  def block
    loop do
      IO.select [@r]
      chunk = @r.gets
      break if chunk == "-adios-"
      yield chunk
    end
  end

  def generate_chunk(text = nil)
    @w.puts text
  end

  def close
    @w.puts "-adios-"
  end
end
