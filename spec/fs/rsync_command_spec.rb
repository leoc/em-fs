require 'spec_helper'

describe EM::FS::RsyncCommand, focus: true do
  context 'copying one file' do
    before :each do
      @source = File.join SPEC_ROOT, 'data', 'test'
      @target = File.join SPEC_ROOT, 'data', 'test.copy'
      @progress_updates   = {}
      @percentage_updates = {}
      @speed_updates      = {}
      EM.run do
        EM::FS.rsync @source, @target do |on|
          on.progress do |file, bytes, percentage, speed|
            (@progress_updates[file] ||= [])   << bytes
            (@percentage_updates[file] ||= []) << percentage
            (@speed_updates[file] ||= [])      << speed
          end

          on.exit do |status|
            EM.stop_event_loop
            raise on.stderr.output if status.exitstatus != 0
          end
        end
      end
    end

    after :each do
      FileUtils.rm_rf @target
    end

    it 'should create a copy' do
      File.should exist @target
    end

    it 'should track progress' do
      @progress_updates['test'].length.should be > 0
      @progress_updates['test'].last.should == 102400
    end

    it 'should track percentages' do
      @percentage_updates.values.flatten.each do |percentage|
        percentage.should be_a Integer
      end
    end

    it 'should track speed' do
      @speed_updates.values.flatten.each do |speed|
        speed.should be_a Float
      end
    end
  end

  context 'copying multiple files' do
    before :each do
      @source1 = File.join SPEC_ROOT, 'data', 'test'
      @source2 = File.join SPEC_ROOT, 'data', 'test2'
      @source3 = File.join SPEC_ROOT, 'data', 'test3'
      @target = File.join SPEC_ROOT, 'data', 'test.dir'
      @progress_updates = {}
      EM.run do
        EM::FS.rsync @source1, @source2, @source3, @target do |on|
          on.progress do |file, bytes|
            (@progress_updates[file] ||= []) << bytes
          end

          on.exit do |status|
            EM.stop_event_loop
            raise on.stderr.output if status.exitstatus != 0
          end
        end
      end
    end

    after :each do
      FileUtils.rm_rf @target
    end

    it 'should create a copy' do
      File.should exist @target
      File.should be_directory @target
      File.should exist File.join(@target, 'test')
      File.should exist File.join(@target, 'test2')
      File.should exist File.join(@target, 'test3')
    end

    it 'should track progress for each file' do
      @progress_updates['test'].length.should be > 0
      @progress_updates['test'].last.should == 102400
      @progress_updates['test2'].length.should be > 0
      @progress_updates['test2'].last.should == 102400
      @progress_updates['test3'].length.should be > 0
      @progress_updates['test3'].last.should == 102400
    end
  end
end
