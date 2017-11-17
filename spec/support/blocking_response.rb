class BlockingResponse
  def initialize
    @r, @w = IO.pipe
  end

  def block
    loop do
      IO.select [@r]
      yield @r.gets
    end
  end

  def generate_chunk(text = nil)
    @w.puts text
  end
end
