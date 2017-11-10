RSpec.describe Servent::Event do
  subject(:event) { described_class.new }

  describe "#parse" do
    context "data:" do
      context 'happy path stream: a simple `data: omg\n\r\n`.' do
        it 'recognizes the simple `data: omg\n\n` pattern as a complete event' do
          event.parse "data:omg\n"
          event.parse "\r\n"

          expect(event.type).to eq "data"
          expect(event.data).to eq "omg"
        end

        it "remove the first space from `data`" do
          event.parse "data: omg\n"
          event.parse "\r\n"

          expect(event.type).to eq "data"
          expect(event.data).to eq "omg"
        end

        it 'recognizes when return comes later: `data: omg\n\n\r`' do
          event.parse "data: omg\n"
          event.parse "\n\r"

          expect(event.type).to eq "data"
          expect(event.data).to eq "omg"
        end

        it 'recognizes when first line is delimited by \r `data: omg\r\n\r`' do
          event.parse "data: omg\n"
          event.parse "\n\r"

          expect(event.type).to eq "data"
          expect(event.data).to eq "omg"
        end
      end
    end
  end
end
