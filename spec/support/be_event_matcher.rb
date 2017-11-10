RSpec::Matchers.define :be_event do |type, data|
  match do |event|
    event.type == type && event.data == data
  end

  failure_message do |event|
    message = ""

    if event.type != type
      message << "expected event#type to be '#{type}' but was '#{event.type}'"
    end

    if event.data != data
      message << "\n" unless message.empty?
      message << "expected event#data to be '#{data}' but was '#{event.data}'"
    end

    message
  end
end
