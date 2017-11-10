RSpec.describe Servent::Event do
  subject(:event) { described_class.new }
  describe "#parse" do
    context ":comment" do
      it "ignores streams starting with `:`" do
        event.parse ":omg! this is a comment\n\r"

        expect(event).to be_empty
      end
    end

    context "data:" do
      context 'happy path stream: a simple `data: omg`' do
        it "remove the first space from `data`" do
          event.parse "data: omg"

          expect(event).to be_message "data", "omg"
        end

        it 'removes just one space from message `data:\s\somg`' do
          event.parse "data:\s\somg"

          expect(event).to be_message "data", " omg"
        end
      end

      context "multiline stream"
    end
  end
end

RSpec::Matchers.define :be_message do |type, data|
  match do |event|
    event.type == type && event.data == data
  end

  failure_message do |event|
    message = ""

    if event.type != type
      message << "expected event#type to be '#{type}' but was #{event.type}"
    end

    if event.data != data
      message << "\n" unless message.empty?
      message << "expected event#data to be '#{data}' but was #{event.data}"
    end

    message
  end
end
