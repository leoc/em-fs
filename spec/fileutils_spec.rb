require 'spec_helper'

describe EM::FileUtils do
  describe '.mkdir' do
    before :all do
      @dir1 = File.join(SPEC_ROOT, 'data', 'dir1')
      @dir2 = File.join(SPEC_ROOT, 'data', 'dir1', 'sub', 'sub', 'sub')
    end

    after :all do
      FileUtils.rm_rf @dir1
      FileUtils.rm_rf @dir2
    end

    it 'should create a directory' do
      EM.run do
        EM::FileUtils.mkdir @dir1 do |on|
          on.success do
            EM.stop_event_loop
            File.should exist(@dir1)
          end
          on.failure do
            raise on.stderr.output
          end
        end
      end
    end

    context 'with :parents options' do
      it 'should create directories for path' do
        EM.run do
          EM::FileUtils.mkdir_p @dir2 do |on|
            on.success do
              EM.stop_event_loop
              File.should exist(@dir2)
            end
            on.failure do
              raise on.stderr.output
            end
          end
        end
      end
    end
  end

  describe '.rmdir' do
    before :all do
      @dir = File.join SPEC_ROOT, 'data', 'testdir'
      FileUtils.mkdir @dir
    end

    after :all do
      FileUtils.rm_rf @dir if File.exists?(@dir)
    end

    it 'should should remove the empty directory' do
      EM.run do
        EM::FileUtils.rmdir @dir do |on|
          on.success do
            EM.stop_event_loop
            File.should_not exist(@dir)
          end
          on.failure do
            raise on.stderr.output
          end
        end
      end
    end
  end

  describe '.ln' do
    before :all do
      @link = File.join SPEC_ROOT, 'data', 'link'
      @target = File.join SPEC_ROOT, 'data', 'link_target'
      FileUtils.touch @target
    end

    after :each do
      FileUtils.rm_rf @link
    end

    it 'should create a link' do
      EM.run do
        EM::FileUtils.ln @target, @link do |on|
          on.success do
            EM.stop_event_loop
            File.should exist(@link)
          end
          on.failure do
            EM.stop_event_loop
            raise on.stderr.output
          end
        end
      end
    end

    it 'should create a symbolic link' do
      EM.run do
        EM::FileUtils.ln_s @target, @link do |on|
          on.success do
            EM.stop_event_loop
            File.should exist @link
          end
          on.failure do
            EM.stop_event_loop
            raise on.stderr.output
          end
        end
      end
    end

    it 'should force link creation' do
      EM.run do
        EM::FileUtils.ln_sf @target, @link do |on|
          on.success do
            EM.stop_event_loop
            File.should exist @link
          end
          on.failure do
            EM.stop_event_loop
            raise on.stderr.output
          end
        end
      end
    end
  end

  describe '.cp' do
    it 'should copy a file'
    it 'should copy files'
    it 'should return a EM::FS::CopyCommand object'
  end

  describe '.cp_r' do
    it 'should copy with :recursive flag'
    it 'should copy directories'
  end

  describe '.mv' do
    it 'should move files'
    it 'should move directories'
    it 'should return a EM::FS::MoveCommand object'
  end

  describe '.rm' do
    it 'should delete a file'
    it 'should fail if directory'
  end

  describe '.rm_r' do
    it 'should delete directories with containing files'
  end

  describe '.rm_rf' do
    it 'should `rm` with :recursive and :force flag'
  end

  describe '.install' do
    it 'should copy files and set mode'
  end

  describe '.chmod' do
    it 'should change mod'
  end

  describe '.chmod_R' do
    it 'should change mod recursively'
  end

  describe '.chown' do
    it 'should change the owner'
  end

  describe '.chown_R' do
    it 'should change the owner recursively'
  end

  describe '.touch' do
    it 'should touch a file'
  end
end
