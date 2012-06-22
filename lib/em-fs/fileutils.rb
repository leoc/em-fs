module EventMachine
  class FileUtils
    class << self
      ##
      # Make directories.
      def mkdir *dirs, &block
        options = { parents: false }.merge dirs.extract_options!
        cmd = EM::SystemCommand.new 'mkdir', &block
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
        cmd = EM::SystemCommand.new 'rmdir'
        cmd << :p if options[:parents]
        cmd << dirs
        cmd.execute &block
      end

      ##
      # Create link in file system.
      def ln src, dest, options = {}, &block
        options = { symbolic: false, force: false }.merge options
        cmd = EM::SystemCommand.new 'ln'
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

      ##
      # Force symbolic link creation.
      def ln_sf src, dest, options = {}, &block
        ln src, dest, options.merge(symbolic: true, force: true), &block
      end

      ##
      # Copy files.
      def cp *args, &block
        options = { recursive: false }.merge args.extract_options!
        unless args.length >= 2
          raise 'Too few arguments. Need source and destination at least.'
        end

        EM::FilesystemCommand.copy *args, options, &block
      end

      ##
      # Recursively copy files.
      def cp_r *args, &block
        options = { recursive: false }.merge args.extract_options!
        cp *args, options.merge(recursive: true), &block
      end

      ##
      # Move files or directories.
      def mv *args, &block
        options = { recursive: false }.merge args.extract_options!
        unless args.length >= 2
          raise 'Too few arguments. Need source and destination at least.'
        end

        EM::FilesystemCommand.move *args, options, &block
      end

      ##
      # Remove files or directories.
      def rm *args, &block
        options = { recursive: false, force: false }.merge args.extract_options!
        cmd = EM::SystemCommand.new 'rm'
        cmd << '-r' if options[:recursive]
        cmd << '-f' if options[:force]
        cmd << args
        cmd.execute &block
      end

      def rm_r target, options = {}, &block
        rm target, options.merge(recursive: true), &block
      end

      def rm_rf target, options = {}, &block
        rm target, options.merge(recursive: true, force: true), &block
      end

      def install *args, &block
        options = { mode: '755' }.merge args.extract_options!
        cmd = EM::SystemCommand.new 'install'
        cmd.add '--mode', options[:mode] if options[:mode]
        cmd << args
        cmd.execute &block
      end

      def chmod mode, *dest, &block
        options = { recursive: false }.merge dest.extract_options!
        cmd = EM::SystemCommand.new 'chmod'
        cmd << :R if options[:recursive]
        cmd << mode << dest
        cmd.execute &block
      end

      def chmod_R mode, *dest, &block
        options = { recursive: false }.merge dest.extract_options!
        chmod mode, *dest, options.merge(recursive: true), &block
      end

      def chown user, group, *dest, &block
        options = { recursive: false }.merge dest.extract_options!
        cmd = EM::SystemCommand.new 'chown'
        cmd << :R if options[:recursive]
        cmd << "#{user.to_s}:#{group.to_s}" << dest
        cmd.execute &block
      end

      def chown_R user, group, *dest, &block
        options = { recursive: false }.merge dest.extract_options!
        chown user, group, dest, options.merge(recursive: true), &block
      end

      def touch *dest, &block
        options = {}.merge dest.extract_options!
        cmd = EM::SystemCommand.new 'touch'
        cmd << dest
        cmd.execute &block
      end
    end
  end
end
