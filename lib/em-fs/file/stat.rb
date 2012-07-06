module EventMachine
  class File
    class Stat

      STAT_REGEX = /(\d+) (\d+) '([\w\/ ]+)' (\d+) (\d+) (\d+) '(.+)' (\d+) (\d+) ([\d.]+) ([\d.]+) ([\d.]+)/.freeze

      # access rights octal
      # ---number of blocks allocated
      # ---the size in bytes of each block reported by %b
      # device number in decimal
      # ---raw mode in hex
      # file type
      # group id
      # number of hardlinks
      # inode number
      # ---mount point
      # file name
      # ---optimal IO transfer size hint
      # total size in bytes
      # --major device type in hex
      # --minor device type in hex
      # user id
      # --time of birth
      # time of last access
      # time of last mod
      # time of last change
      STAT_FORMAT =
        "%a %d '%F' %g %h %i '%n' %s %u %X %Y %Z"

      # Types
      S_IFBLK   = 0b00000001 # block device
      S_IFCHR   = 0b00000010 # character device
      S_IFDIR   = 0b00000100 # directory
      S_IFIFO   = 0b00001000 # FIFO/pipe
      S_IFLNK   = 0b00010000 # symlink
      S_IFREG   = 0b00100000 # regular file
      S_IFSOCK  = 0b01000000 # socket
      S_UNKNOWN = 0b10000000 # unknown

      # Mode Flags
      S_IRUSR   = 0b100000000
      S_IWUSR   = 0b010000000
      S_IXUSR   = 0b001000000
      S_IRGRP   = 0b000100000
      S_IWGRP   = 0b000010000
      S_IXGRP   = 0b000001000
      S_IROTH   = 0b000000100
      S_IWOTH   = 0b000000010
      S_IXOTH   = 0b000000001

      class << self

        ##
        # Parses a given string for file stat information.
        #
        # @param [String] string The String to be parsed.
        # @return [EM::File::Stat] The file stat object.
        def parse str
          if m = str.match(STAT_REGEX)
            ftype = case m[3]
                    when 'block device' then S_IFBLK
                    when 'character device' then S_IFCHR
                    when 'directory' then S_IFDIR
                    when 'FIFO/pipe' then S_IFIFO
                    when 'symlink' then S_IFLNK
                    when 'regular file' then S_IFREG
                    when 'socket' then S_IFSOCK
                    else
                      S_UNKNOWN
                    end
            EM::File::Stat.new path:  m[7],
                               atime: Time.at(Integer(m[10].split('.')[0], 10)),
                               ctime: Time.at(Integer(m[12].split('.')[0], 10)),
                               dev:   Integer(m[2], 10),
                               ftype: ftype,
                               gid:   Integer(m[4], 10),
                               ino:   Integer(m[6], 10),
                               mode:  Integer(m[1], 8),
                               mtime: Time.at(Integer(m[11].split('.')[0], 10)),
                               nlink: Integer(m[5], 10),
                               size:  Integer(m[8], 10),
                               uid:   Integer(m[9], 10)
          else
            raise "Unable to parse stat string: #{str}"
          end
        end
      end

      attr_reader :path, :atime, :ctime, :dev, :ftype, :gid,
                  :ino, :mtime, :nlink, :size, :uid

      def initialize val = {}
        @path       = val[:path]
        @atime      = val[:atime]
        @ctime      = val[:ctime]
        @dev        = val[:dev]
        @ftype      = val[:ftype]
        @gid        = val[:gid]
        @ino        = val[:ino]
        @mode       = val[:mode]
        @mtime      = val[:mtime]
        @nlink      = val[:nlink]
        @size       = val[:size]
        @uid        = val[:uid]
      end

      def blockdev?
        ftype^S_IFBLK == 0
      end

      def chardev?
        ftype^S_IFCHR == 0
      end

      def directory?
        ftype^S_IFDIR == 0
      end

      def executable?
        return true if Process::UID.rid == 0
        return @mode & S_IXUSR != 0 if rowned?
        return @mode & S_IXGRP != 0 if rgrpowned?
        @mode & S_IXOTH != 0
      end

      def executable_real?
        return true if Process::UID.rid == 0
        return @mode & S_IXUSR != 0 if rowned?
        return @mode & S_IXGRP != 0 if rgrpowned?
        @mode & S_IXOTH != 0
      end

      def file?
        ftype^S_IFREG == 0
      end

      def grpowned?
        gid == Process::GID.eid
      end

      def rgrpowned?
        gid == Process::GID.rid
      end

      def mode
        @mode.to_s(8)
      end

      def owned?
        uid == Process::UID.eid
      end

      def rowned?
        uid == Process::UID.rid
      end

      def pipe?
        ftype^S_IFIFO == 0
      end

      def readable?
        return true if Process::UID.eid == 0
        return @mode & S_IRUSR != 0 if owned?
        return @mode & S_IRGRP != 0 if grpowned?
        @mode & S_IROTH != 0
      end

      def readable_real?
        return true if Process::UID.rid == 0
        return @mode & S_IRUSR != 0 if rowned?
        return @mode & S_IRGRP != 0 if rgrpowned?
        @mode & S_IROTH != 0
      end

      def socket?
        ftype^S_IFSOCK == 0
      end

      def symlink?
        ftype^S_IFLNK == 0
      end

      def world_readable?
        @mode if @mode & S_IROTH == S_IROTH
      end

      def world_writable?
        @mode if @mode & S_IWOTH == S_IWOTH
      end

      def writable?
        return true if Process::UID.rid == 0
        return @mode & S_IWUSR != 0 if owned?
        return @mode & S_IWGRP != 0 if grpowned?
        @mode & S_IWOTH != 0
      end

      def writable_real?
        return true if Process::UID.rid == 0
        return @mode & S_IWUSR != 0 if rowned?
        return @mode & S_IWGRP != 0 if rgrpowned?
        @mode & S_IWOTH != 0
      end

      def zero?
        @size == 0
      end

    end
  end
end
