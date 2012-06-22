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

    after :all do
      FileUtils.rm_rf @target
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

    context 'copying one file' do
      before :all do
        @source = File.join SPEC_ROOT, 'data', 'test'
        @target = File.join SPEC_ROOT, 'data', 'test.copy'
        @progress_updates = {}
        EM.run do
          EM::FileUtils.cp @source, @target do |on|
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

      after :all do
        FileUtils.rm_rf @target
      end

      it 'should create a copy' do
        File.should exist @target
      end

      it 'should update progress' do
        @progress_updates['test'].length.should be > 0
        @progress_updates['test'].last.should == 102400
      end
    end

    context 'copying multiple files to folder' do
      before :all do
        @source1 = File.join SPEC_ROOT, 'data', 'test'
        @source2 = File.join SPEC_ROOT, 'data', 'test2'
        @source3 = File.join SPEC_ROOT, 'data', 'test3'
        @target = File.join SPEC_ROOT, 'data', 'test.dir'
        @progress_updates = {}
        EM.run do
          EM::FileUtils.cp @source1, @source2, @source3, @target do |on|
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

      after :all do
        FileUtils.rm_rf @target
      end

      it 'should create a copy' do
        File.should exist @target
        File.should be_directory @target
        File.should exist File.join(@target, 'test')
        File.should exist File.join(@target, 'test2')
        File.should exist File.join(@target, 'test3')
      end

      it 'should update progress' do
        @progress_updates['test'].length.should be > 0
        @progress_updates['test'].last.should == 102400
        @progress_updates['test2'].length.should be > 0
        @progress_updates['test2'].last.should == 102400
        @progress_updates['test3'].length.should be > 0
        @progress_updates['test3'].last.should == 102400
      end
    end
  end

  describe '.cp_r' do
    before :all do
      @progress_updates = {}
      @source_dir = File.join(SPEC_ROOT, 'data', 'source.dir/')
      @target_dir = File.join(SPEC_ROOT, 'data', 'target.dir')
      FileUtils.mkdir_p @source_dir
      FileUtils.cp [
                    File.join(SPEC_ROOT, 'data', 'test'),
                    File.join(SPEC_ROOT, 'data', 'test2'),
                    File.join(SPEC_ROOT, 'data', 'test3')
                   ], @source_dir

      EM.run do
        EM::FileUtils.cp_r @source_dir, @target_dir do |on|
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

    after :all do
      FileUtils.rm_rf @source_dir
      FileUtils.rm_rf @target_dir
    end

    it 'should copy directory recursively' do
      File.should exist File.join(@target_dir, 'test')
      File.should exist File.join(@target_dir, 'test2')
      File.should exist File.join(@target_dir, 'test3')
    end

    it 'should update progress infos' do
      @progress_updates['test'].length.should be > 0
      @progress_updates['test'].last.should == 102400
      @progress_updates['test2'].length.should be > 0
      @progress_updates['test2'].last.should == 102400
      @progress_updates['test3'].length.should be > 0
      @progress_updates['test3'].last.should == 102400
    end
  end

  describe '.mv' do
    context 'moving one file' do
      before :all do
        @progress_updates = {}
        @source = File.join(SPEC_ROOT, 'data', 'test')
        @target = File.join(SPEC_ROOT, 'data', 'moved_test')

        EM.run do
          EM::FileUtils.mv @source, @target do |on|
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

      after :all do
        FileUtils.mv @target, @source
      end

      it 'should copy to target file' do
        File.should exist @target
      end

      it 'should remove source file' do
        File.should_not exist @source
      end
    end

    context 'moving multiple files' do
      before :all do
        @progress_updates = {}
        @source = File.join(SPEC_ROOT, 'data', 'test')
        @source2 = File.join(SPEC_ROOT, 'data', 'test2')
        @source3 = File.join(SPEC_ROOT, 'data', 'test3')
        @target_dir = File.join(SPEC_ROOT, 'data', 'target_dir')

        EM.run do
          EM::FileUtils.mv @source, @source2, @source3, @target_dir do |on|
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

      after :all do
        FileUtils.mv Dir.glob(File.join(@target_dir, '*')), File.join(SPEC_ROOT, 'data')
        FileUtils.rm_rf @target_dir
      end

      it 'should copy to target directory' do
        File.should exist File.join(@target_dir, 'test')
        File.should exist File.join(@target_dir, 'test2')
        File.should exist File.join(@target_dir, 'test3')
      end

      it 'should remove source files' do
        File.should_not exist @source
        File.should_not exist @source2
        File.should_not exist @source3
      end

      it 'should update progresses' do
        @progress_updates['test'].length.should be > 0
        @progress_updates['test'].last.should == 102400
        @progress_updates['test2'].length.should be > 0
        @progress_updates['test2'].last.should == 102400
        @progress_updates['test3'].length.should be > 0
        @progress_updates['test3'].last.should == 102400
      end
    end

    context 'moving directories' do
      before :all do
        @progress_updates = {}
        @source_dir = File.join(SPEC_ROOT, 'data', 'source.dir/')
        @target_dir = File.join(SPEC_ROOT, 'data', 'target.dir')
        FileUtils.mkdir_p @source_dir
        FileUtils.cp [
                      File.join(SPEC_ROOT, 'data', 'test'),
                      File.join(SPEC_ROOT, 'data', 'test2'),
                      File.join(SPEC_ROOT, 'data', 'test3')
                     ], @source_dir

        EM.run do
          EM::FileUtils.mv @source_dir, @target_dir do |on|
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

      after :all do
        FileUtils.rm_rf @target_dir
        FileUtils.rm_rf @source_dir
      end

      it 'should delete the source directory' do
        File.should_not exist File.join(@source_dir, 'test')
        File.should_not exist File.join(@source_dir, 'test2')
        File.should_not exist File.join(@source_dir, 'test3')
      end

      it 'should create the target directory' do
        File.should exist @target_dir
      end

      it 'should have moved the directory content to the target directory' do
        File.should exist File.join(@target_dir, 'test')
        File.should exist File.join(@target_dir, 'test2')
        File.should exist File.join(@target_dir, 'test3')
      end
    end
  end

  describe '.rm' do
    it 'should invoke `rm file`' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.rm 'file'
        cmd.command.should == 'rm file'
        EM.stop_event_loop
      end
    end
  end

  describe '.rm_r' do
    it 'should invoke `rm file`' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.rm_r 'file'
        cmd.command.should == 'rm -r file'
        EM.stop_event_loop
      end
    end
  end

  describe '.rm_rf' do
    it 'should invoke `rm file`' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.rm_rf 'file'
        cmd.command.should == 'rm -r -f file'
        EM.stop_event_loop
      end
    end
  end

  describe '.install' do
    it 'should invoke `install` command' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.install 'file', '/usr/bin/test', mode: '777'
        cmd.command.should == 'install --mode=777 file /usr/bin/test'
        EM.stop_event_loop
      end
    end
  end

  describe '.chmod' do
    it 'should invoke `chmod` command' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.chmod 777, '/usr/bin/test'
        cmd.command.should == 'chmod 777 /usr/bin/test'
        EM.stop_event_loop
      end
    end
  end

  describe '.chmod_R' do
    it 'should invoke `chmod -R` command' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.chmod_R 777, '/usr/bin/test'
        cmd.command.should == 'chmod -R 777 /usr/bin/test'
        EM.stop_event_loop
      end
    end
  end

  describe '.chown' do
    it 'should invoke `chown`' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.chown 'arthur', 'users', '/usr/bin/test'
        cmd.command.should == 'chown arthur:users /usr/bin/test'
        EM.stop_event_loop
      end
    end
  end

  describe '.chown_R' do
    it 'should invoke `chown -r`' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.chown_R 'arthur', 'users', '/usr/bin/test'
        cmd.command.should == 'chown -R arthur:users /usr/bin/test'
        EM.stop_event_loop
      end
    end
  end

  describe '.touch' do
    it 'should invoke `touch`' do
      EM.run do
        @dir = File.join(SPEC_ROOT, 'data', 'test')
        cmd = EM::FileUtils.touch '/usr/bin/test'
        cmd.command.should == 'touch /usr/bin/test'
        EM.stop_event_loop
      end
    end
  end
end
