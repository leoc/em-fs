# -*- coding: utf-8 -*-
module EventMachine
  class FS
    class Command < EM::SystemCommand

      PROGRESS_REGEXP = /([A-Za-z0-9\.\-\/]+)\n[ ]+(\d+)/.freeze

      ##
      # Invokes `#execute` of super-class and adds a progress matcher.
      def execute &block
        super &block

        stdout.match PROGRESS_REGEXP, match: :last, in: :output do |file, bytes|
          receive_progress file, bytes.to_i
        end

        self
      end

      ##
      # Is called when ever a `EM::FilesystemCommand` stdout updates the line
      # is matched the `EM::FilesystemCommand::PROGRESS_REGEXP`.
      #
      # Calls all defined callbacks for progress events.
      #
      # @param [String] file The file that´s been updated.
      # @param [Integer] bytes The bytes moved or copied.
      def receive_progress file, bytes
        progress_callbacks.each do |cb|
          cb.call file, bytes
        end
      end

      ##
      # Defines a progress callback.
      #
      # @yield The block to be stored as callback for progress events.
      # @yieldparam [String] file The file that´s been updated.
      # @yieldparam [Integer] bytes The bytes moved or copied.
      def progress &block
        progress_callbacks << block
      end

      ##
      # The callbacks for progress events.
      #
      # @return [Array] The array of callbacks for progress events.
      private
      def progress_callbacks
        @progress_callbacks ||= []
      end

      def progress_regexp
        @progress_regexp ||= /([A-Za-z0-9\.\-\/]+)\n[ ]+(\d+)/.freeze
      end
    end
  end
end
