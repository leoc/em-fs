module EventMachine
  class FileUtils
    class << self
      ##
      # Make directories.
      def mkdir *dirs, &block
        options = { parents: false }.merge dirs.extract_options!
        cmd = EM::FS::Command.new 'mkdir', &block
        cmd << :p if options[:parents]
        cmd << dirs
        cmd.execute
      end

      ##
      # Make directories with parents.
      def mkdir_p *dirs, &block
        options = {}.merge dirs.extract_options!
        mkdir *dirs, options.merge(parents: true), &block
      end

      ##
      # Remove the directories if they are empty.
      def rmdir *dirs, &block
        options = { parents: false }.merge dirs.extract_options!
        cmd = EM::FS::Command.new 'rmdir'
        cmd << :p if options[:parents]
        cmd << dirs
        cmd.execute &block
      end

      ##
      # Create link in file system.
      def ln src, dest, options = {}, &block
        options = { symbolic: false, force: false }.merge options
        cmd = EM::FS::Command.new 'ln'
        cmd << :s if options[:symbolic]
        cmd << :f if options[:force]
        cmd << src << dest
        cmd.execute &block
      end

      ##
      # Create symbolic link.
      def ln_s src, dest, options = {}, &block
        ln src, dest, options.merge(symbolic: true), &block
      end

      # Force symbolic link creation.
      def ln_sf src, dest, options = {}, &block
        ln src, dest, options.merge(symbolic: true, force: true), &block
      end

      # Copy files.
      def cp *args, &block
        options = { recursive: false }.merge args.extract_options!
        unless args.length >= 2
          raise 'Too few arguments. Need source and destination at least.'
        end
        dest = args.pop
        EM::FS::CopyCommand.new *args, dest, options, block
      end

      def cp_r *args, &block
        options = { recursive: false }.merge args.extract_options!
        cp(*args, options.merge(recursive: true))
      end

      def mv src, dest, options
        options = { recursive: false }
      end

      def rm *args, &block
        options = { recursive: false, force: false }.merge args.extract_options!
        cmd = EM::FS::Command.new cmd, src
        cmd << :r if options[:recursive]
        cmd << :f if options[:force]
        cmd.execute &block
      end

      def rm_r target, options = {}, &block
        rm target, options.merge(recursive: true), &block
      end

      def rm_rf target, options = {}, &block
        rm target, options.merge(recursive: true, force: true), &block
      end

      def install src, dest, mode = nil, options = {}

        cmd = EM::FS::Command.new cmd, src
        cmd << src << dest
        cmd.execute &block
      end

      def chmod mode, *dest, &block
        options = { recursive: false }.merge dest.extract_options!
        cmd = EM::FS::Command.new 'chmod'
        cmd << :R if options[:recursive]
        cmd << mode << dest
        cmd.execute &block
      end

      def chmod_R mode, *dest, &block
        options = { recursive: false }.merge dest.extract_options!
        chmod mode, dest, options.merge(recursive: true), block
      end

      def chown user, group, *dest, &block
        options = { recursive: false }.merge dest.extract_options!
        cmd = EM::FS::Command.new 'chown'
        cmd << :r if options[:recursive]
        cmd << :f if options[:force]
        cmd << "#{user.to_s}:#{group.to_s}" << dest
        cmd.execute &block
      end

      def chown_R user, group, *dest, &block
        options = { recursive: false }.merge dest.extract_options!
        chown user, group, dest, options.merge(recursive: true), block
      end

      def touch *dest, &block
        options = {}.merge dest.extract_options!

      end
    end
  end
end
