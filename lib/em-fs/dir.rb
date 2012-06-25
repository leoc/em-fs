require 'em-fs/dir/glob'

module EventMachine
  class Dir
    class << self

      def glob pattern
        EM::Dir::Glob.new pattern
      end
      alias :[] :glob

    end
  end
end
