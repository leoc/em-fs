module EventMachine
  class Dir
    class Glob

      FORMAT = "%m %D '%y' %G %n %i '%p' %s %U %A@ %T@ %C@\\n"

      def initialize pattern
        @weight = nil
        parse pattern
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
          depth: :inf
        }.merge options
        EM::SystemCommand.execute find_command(options) do |on|
          on.stdout.line do |line|
            block.call File::Stat.parse line
          end
        end
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
          depth: (@weight || :inf)
        }.merge options

        builder = EM::SystemCommand::Builder.new 'find'
        builder << @root
        builder << [ :path, @path ] unless @path == "*" or @path == ''
        builder << [ :name, @name ] unless @name == "*"
        builder << [ :maxdepth, options[:depth] ] unless options[:depth] == :inf
        builder << [ :printf, FORMAT ]
        builder.to_s.gsub(/-+(\w)/, "-\\1")
      end

    end
  end
end
