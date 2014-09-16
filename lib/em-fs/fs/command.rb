# -*- coding: utf-8 -*-
module EventMachine
  class FS
    class Command < EM::SystemCommand
      PROGRESS_REGEXP = /([^\n]+)\n[ ]+([^ ]+)[ ]+(.+)%/.freeze

      ##
      # Invokes `#execute` of super-class and adds a progress matcher.
      def execute &block
        super &block

        last_progress    = 0
        last_progress_at = Time.new.to_f
        stdout.match PROGRESS_REGEXP, match: :last, in: :output do |file, total_bytes, percentage|
          progress = total_bytes.gsub(/[^\d]/,'').to_i
          progress_at = Time.new.to_f
          speed = (progress - last_progress) / (progress_at - last_progress_at)

          receive_progress(file, progress, percentage.to_i, speed)

          last_progress    = progress
          last_progress_at = progress_at
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
      def receive_progress *args
        progress_callbacks.each do |cb|
          cb.call(*args)
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
    end
  end
end
