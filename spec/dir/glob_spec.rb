# -*- coding: utf-8 -*-
require 'spec_helper'

describe EM::Dir::Glob do
  before :all do
    dirs = [ 'a', 'b/a', 'b/b', 'c/a/a', 'c/a/b' ].map { |p|
      File.join(SPEC_ROOT, 'data', p)
    }
    files = [ 'a/x', 'b/x', 'b/a/x', 'b/a/y', 'b/a/z' ].map { |p|
      File.join(SPEC_ROOT, 'data', p)
    }
    FileUtils.mkdir_p dirs
    FileUtils.touch files
  end

  describe '#find_command' do
    it 'should parse relative pattern' do
      cmd = EM::Dir['./*.rb'].send :find_command
      cmd.should == "find . -name '*.rb' -maxdepth 1 -printf '%m %D '\\''%y'\\'' %G %n %i '\\''%p'\\'' %s %U %A@ %T@ %C@\\n'"
    end

    it 'should parse relative pattern with path wildcard' do
      cmd = EM::Dir['./**/*.rb'].send :find_command
      cmd.should == "find . -name '*.rb' -printf '%m %D '\\''%y'\\'' %G %n %i '\\''%p'\\'' %s %U %A@ %T@ %C@\\n'"
    end
  end

  describe '#each' do
    context 'with depth = 0' do
      before :all do
        @entries = []
        pattern = File.join(SPEC_ROOT, 'data', '**', '*')
        EM.run do
          cmd = EM::Dir[pattern].each depth: 1 do |entry|
            @entries << entry.path
          end

          cmd.exit do
            EM.stop_event_loop
          end
        end
      end

      it 'should execute the block for each entry' do
        @entries.should =~ [
                            "data",
                            "data/b",
                            "data/c",
                            "data/test2",
                            "data/test",
                            "data/a",
                            "data/test3"
                           ].map {|e| File.join(SPEC_ROOT, e)}
      end
    end

    context 'with depth = 2' do
      before :all do
        @entries = []
        pattern = File.join(SPEC_ROOT, 'data', '**', '*')
        EM.run do
          cmd = EM::Dir[pattern].each depth: 2 do |entry|
            @entries << entry.path
          end

          cmd.exit do
            EM.stop_event_loop
          end
        end
      end

      it 'should execute the block for each entry and directory´s entry' do
        @entries.should =~ [
                            "data",
                            "data/b",
                            "data/b/b",
                            "data/b/x",
                            "data/b/a",
                            "data/c",
                            "data/c/a",
                            "data/test2",
                            "data/test",
                            "data/a",
                            "data/a/x",
                            "data/test3"
                           ].map {|e| File.join(SPEC_ROOT, e)}
      end
    end

    context 'with depth = :inf' do
      before :all do
        @entries = []
        pattern = File.join(SPEC_ROOT, 'data', '**', '*')
        EM.run do
          cmd = EM::Dir[pattern].each depth: :inf do |entry|
            @entries << entry.path
          end

          cmd.exit do
            EM.stop_event_loop
          end
        end
      end

      it 'should execute the block for each entry in tree' do
        @entries.should =~ [
                            "data",
                            "data/b",
                            "data/b/b",
                            "data/b/x",
                            "data/b/a",
                            "data/b/a/x",
                            "data/b/a/z",
                            "data/b/a/y",
                            "data/c",
                            "data/c/a",
                            "data/c/a/b",
                            "data/c/a/a",
                            "data/test2",
                            "data/test",
                            "data/a",
                            "data/a/x",
                            "data/test3"
                           ].map {|e| File.join(SPEC_ROOT, e)}
      end
    end
  end

  describe '#each_entry' do
    before :all do
      @entries = []
      pattern = File.join(SPEC_ROOT, 'data', '**', '*')
      EM.run do
        cmd = EM::Dir[pattern].each_entry do |entry|
          @entries << entry
        end

        cmd.exit do
          EM.stop_event_loop
        end
      end
    end

    it 'should execute a block with file name for each entry' do
        @entries.should =~ [ "data", "b", "c", "test2", "test", "a", "test3" ]
      end
  end

  describe '#each_path' do
    before :all do
      @entries = []
      pattern = File.join(SPEC_ROOT, 'data', '**', '*')
      EM.run do
        cmd = EM::Dir[pattern].each_path do |path|
          @entries << path
        end

        cmd.exit do
          EM.stop_event_loop
        end
      end
    end

    it 'should execute a block with full path for each entry' do
        @entries.should =~ [
                            "data",
                            "data/b",
                            "data/b/b",
                            "data/b/x",
                            "data/b/a",
                            "data/b/a/x",
                            "data/b/a/z",
                            "data/b/a/y",
                            "data/c",
                            "data/c/a",
                            "data/c/a/b",
                            "data/c/a/a",
                            "data/test2",
                            "data/test",
                            "data/a",
                            "data/a/x",
                            "data/test3"
                           ].map {|e| File.join(SPEC_ROOT, e)}
      end
  end
end
