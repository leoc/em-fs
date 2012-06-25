require 'em-fs/fs/command'
require 'em-fs/fs/rsync_command'

module EventMachine
  class FS
    class << self

      def rsync *args, &block
        options = { }.merge args.extract_options!
        cmd = EM::FS::RsyncCommand.new
        cmd << :progress
        cmd << args
        cmd.execute &block
      end

      def find *args, &block
        options = { }.merge args.extract_options!
        cmd = EM::SystemCommand.new 'find'
        cmd << args
        cmd.execute &block
      end

    end
  end
end
