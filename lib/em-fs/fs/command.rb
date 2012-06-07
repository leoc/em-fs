module EventMachine
  module FS
    class Command < EM::SystemCommand
      def receive_progress progress
        progress_callbacks.each do |callback|
          callback.call progress
        end
      end

      def progress &block
        progress_callbacks << block
      end

      private
      def progress_callbacks
        @progress_callbacks ||= []
      end
    end
  end
end
