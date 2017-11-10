require "webrick"

class SSEEvent
  def initialize(text, type: "message", id: Time.now.to_f)
    @id   = id
    @text = text
    @type = type
  end

  def event
    %(event: #{@type}
id: #{@id}
data: {
data: "id": "#{@id}",
data: "type": "#{@type}",
data: "text": "#{@text}"
data: }

)
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

server.mount_proc "/broadcast" do |_, _|
  clients.each do |client|
    Thread.new do
      client << SSEEvent.new("streaming!").event
    end
  end
end

trap :INT do
  clients.each(&:close)
  server.shutdown
end

server.start
