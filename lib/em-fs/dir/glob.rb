module EventMachine
  class Dir
    class Glob

      FORMAT = "%m %D '%y' %G %n %i '%p' %s %U %A@ %T@ %C@\\n"

      def initialize pattern
        @weight = nil
        @type = nil
        @finished_callbacks = []
        parse pattern
      end

      def finish &block
        @finished_callbacks << block
      end

      def parse pattern
        root = []

        *path, name = pattern.split(::File::SEPARATOR)

        if name.index("*").nil?
          path << name
          name = "*"
        end

        root << path.shift while path[0] and path[0].index("*").nil?

        @name = name
        @path = path.join(::File::SEPARATOR).gsub '**', '*'
        @root = root.join(::File::SEPARATOR)

        if path.length == 0
          @weight = 1
        end

        @root = '.' if @root == ''
      end

      def each options = {}, &block
        options = {
          depth: :inf,
          type: :all
        }.merge options

        EM::SystemCommand.execute find_command(options) do |on|
          stats = []
          on.stdout.line do |line|
            stat = File::Stat.parse(line)
            stats << stat
            block.call(stat) if block
          end
          on.success do
            @finished_callbacks.each do |callback|
              callback.call(stats)
            end
          end
        end
        self
      end

      def each_entry options = {}, &block
        options = {
          depth: 1
        }.merge options
        each options do |stat|
          block.call ::File.basename(stat.path)
        end
      end

      def each_path options = {}, &block
        options = {
          depth: :inf
        }.merge options
        each options do |stat|
          block.call stat.path
        end
      end

      private
      def find_command options = {}
        options = {
          depth: (@weight || :inf),
          type: (@type || :all)
        }.merge options

        builder = EM::SystemCommand::Builder.new 'find'
        builder << @root
        builder << [ :path, @path ] unless @path == "*" or @path == ''
        builder << [ :name, @name ] unless @name == "*"
        builder << [ :maxdepth, options[:depth] ] unless options[:depth] == :inf
        builder << [ :type, options[:type] ] unless options[:type] == :all
        builder << [ :printf, FORMAT ]
        builder.to_s.gsub(/-+(\w)/, "-\\1")
      end

    end
  end
end
