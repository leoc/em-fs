module EventMachine
  class Dir
    class Listing < EM::Queue

      ##
      # Creates a new directory listing object. Usually it
      def initialize

      end

      ##
      # The getter for the stat callbacks.
      def callbacks
        @callbacks ||= []
      end

      ##
      # The getter for the entry callbacks.
      def entry_callbacks
        @entry_callbacks ||= []
      end

      ##
      # The getter for the path callbacks.
      def path_callbacks
        @path_callbacks ||= []
      end

      ##
      # The queue that contains all entries.
      def listing_queue
        @listing_queue ||= EM::Queue.new
      end

      ##
      # Invoked by the system command that crawls the
      def parse_entry line

      end

    end
  end
end
