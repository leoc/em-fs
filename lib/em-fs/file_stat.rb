module EventMachine
  class File
    class Stat
      class << self
        ##
        # Parses a given string for file stat information.
        #
        # @param [String] string The String to be parsed.
        # @return [EM::File::Stat] The file stat object.
        def parse str
          stat = EM::File::Stat.new
          # TODO: set stats
          stat
        end

        ##
        # Loads the stat via system command.
        def get file, &block

        end
      end

      def initialize

      end
    end
  end
end
