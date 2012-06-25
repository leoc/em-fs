require 'spec_helper'

describe EM::FS do
  describe '.rsync' do
    it 'should create an `RsyncCommand` with :progress flag' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FS.rsync '/usr/share/test1', '/usr/share/test2'
        cmd.should be_a EM::FS::RsyncCommand
        cmd.command.should == 'rsync --progress /usr/share/test1 /usr/share/test2'
        EM.stop_event_loop
      end
    end
  end

  describe '.find' do
    it 'should create `SystemCommand`' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FS.find '.'
        cmd.should be_a EM::SystemCommand
        cmd.command.should == 'find .'
        EM.stop_event_loop
      end
    end
  end

end
