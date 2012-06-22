module EventMachine
  class DirListing < EM::Queue

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
    # Adds a block as finished callback, that is invoked, when the
    # process is finished and the queue is empty.
    def finished &block
      finished_callbacks << block
    end

    def finished_callbacks
      @finished_callbacks ||= []
    end

    def call_finished_callbacks
      finished_callbacks.each do |cb|
        cb.call
      end
    end

    ##
    # Invoked by the system command that crawls the
    def parse_entry line

    end

    ##
    # Used to set a callback for when an entry gets added.
    # The given block
    def each options = {}, &block
      EM::SystemCommand 'find'
    end

    ##
    # Used to set a callback for when an entry gets added.
    def each_entry options = {}, &block

    end

    def each_path options = {}, &block

    end

  end
end


module EventMachine
  # A cross thread, reactor scheduled, linear queue.
  #
  # This class provides a simple "Queue" like abstraction on top of the reactor
  # scheduler. It services two primary purposes:
  # * API sugar for stateful protocols
  # * Pushing processing onto the same thread as the reactor
  #
  # See examples/ex_queue.rb for a detailed example.
  #
  #  q = EM::Queue.new
  #  q.push('one', 'two', 'three')
  #  3.times do
  #    q.pop{ |msg| puts(msg) }
  #  end
  #
  class Queue
    # Create a new queue
    def initialize
      @items = []
      @popq  = []
    end



    def pop(*a, &b)
      cb = EM::Callback(*a, &b)
      EM.schedule do
        if @items.empty?
          @popq << cb
        else
          cb.call @items.shift
        end
        call_finished_callbacks if empty?
      end
      nil # Always returns nil
    end

    def push(*items)
      EM.schedule do
        @items.push(*items)
        @popq.shift.call @items.shift until @items.empty? || @popq.empty?
      end
    end

    def empty?
      @items.empty?
    end

    def size
      @items.size
    end
  end
end
