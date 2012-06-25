require 'spec_helper'

describe EM::File do
  describe '.stat' do
    before :all do
      @stat = nil
      EM.run do
        EM::File.stat File.join(SPEC_ROOT, 'data') do |stat|
          @stat = stat
          EM.stop_event_loop
        end
      end
    end

    it 'should return a `EM::File::Stat`' do
      @stat.should be_a EM::File::Stat
    end
  end
end
