require 'eventmachine'
require 'em-fs'

SPEC_ROOT = File.expand_path(File.dirname(__FILE__))

EventMachine.instance_eval do
  def assertions time = 1
    EM.add_timer(time) do
      EM.stop_event_loop
      yield
    end
  end
end unless EM.respond_to?(:assertions)

unless File.exists?(File.join(SPEC_ROOT, 'data', 'test'))
  puts "Creating test dummy data"
  system "mkdir -p #{File.join(SPEC_ROOT, 'data')}"
  system "dd if=/dev/urandom of=#{File.join(SPEC_ROOT, 'data', 'test')} bs=1024 count=1000000"
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
