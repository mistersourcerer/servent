require "net/http"
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "servent"
require "pp"

event_source = Servent::EventSource.new("http://localhost:9292/")
event_source.on_message do |event|
  if event.data == "close"
    puts "going to close this client"
    return event_source.close
  end

  puts "received: "+ event.data
end
event_source.listen

puts "bye"
