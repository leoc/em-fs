module EventMachine
  class FS
    class RsyncCommand < EM::FS::Command

      def initialize
        super 'rsync'
      end

    end
  end
end
