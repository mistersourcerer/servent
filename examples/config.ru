require "webrick"

class SSEEvent
  def initialize(text, type: "message", id: Time.now.to_f)
    @id   = id
    @text = text
    @type = type
  end

  def event
    <<~EVENT
      event: #{@type}
      id: #{@id}
      data: #{@text}

    EVENT
  end
end

server = WEBrick::HTTPServer.new Port: 9292

clients = []

server.mount_proc "/" do |_, res|
  r, w = IO.pipe
  clients << w

  res.content_type = "text/event-stream"
  res.body = r
  res.chunked = true
end

server.mount_proc "/broadcast" do |req, _|
  repeat = req.query["repeat"].to_i
  repeat = 1 if repeat <= 0 || repeat.nil?

  clients.each do |client|
    repeat.times do |counter|
      client << SSEEvent.new("streaming #{counter}!").event
    end
  end
end

server.mount_proc "/enough" do |_, _|
  clients.each do |client|
    client << SSEEvent.new("close").event
  end
end

trap :INT do
  clients.each(&:close)
  server.shutdown
end

server.start
