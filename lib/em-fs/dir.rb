require 'em-fs/dir/glob'
require 'em-fs/dir/listing'

module EventMachine
  class Dir
    class << self


      def each expr, options = {}, &block

      end

      ##
      # Executes a block for each entry for a given directory with the
      # basename as parameter. (Look at `EM::Dir.each` for additional
      # options)
      def each_entry expr, options = {}, &block
        options.merge! depth: 0
        each expr, options do |stat|
          block.call stat.filename
        end
      end

      ##
      # Executes a block for each entry for a given directory with the
      # full path for that entry as parameter. (Look at `EM::Dir.each`
      # for additional options)
      def each_path expr, options = {}

      end
    end
  end
end
