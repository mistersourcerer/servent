RSpec.describe Servent::Event do
  subject(:event) { described_class.new }
  describe "#parse" do
    context "data:" do
      context 'happy path stream: a simple `data: omg\n\r\n`.' do
        it 'recognizes simple `data: omg\n\n` pattern as a complete event' do
          event.parse "data:omg\n\r\n"

          expect(event).to be_data "omg"
        end

        it "remove the first space from `data`" do
          event.parse "data: omg\n\r\n"

          expect(event).to be_data "omg"
        end

        it 'recognizes when return comes later: `data: omg\n\n\r`' do
          event.parse "data: omg\n\n\r"

          expect(event).to be_data "omg"
        end

        it 'recognizes when first line is delimited by \r `data: omg\r\n\r`' do
          event.parse "data: omg\n\n\r"

          expect(event).to be_data "omg"
        end
      end
    end
  end
end

RSpec::Matchers.define :be_data do |data|
  match do |event|
    event.type == "data" && event.data == data
  end

  failure_message do |event|
    message = ""

    if event.type != "data"
      message << "expected event#type to be 'data' but was #{event.type}"
    end

    if event.data != data
      message << "\n" unless message.empty?
      message << "expected event#data to be '#{data}' but was #{event.data}"
    end

    message
  end
end
