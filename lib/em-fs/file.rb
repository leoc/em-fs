require 'em-fs/file/stat'

module EventMachine
  class File

    class << self

      def stat path, &block
        EM::SystemCommand.execute 'stat', [:format, EM::File::Stat::STAT_FORMAT], path do |on|
          on.success do |ps|
            block.call EM::File::Stat.parse ps.stdout.output
          end
          on.failure do |ps|
            raise "EM::File::stat failed. Output:\n#{ps.stderr.output}"
          end
        end
      end

    end
  end
end
