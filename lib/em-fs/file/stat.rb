module EventMachine
  class File
    class Stat

      STAT_REGEX = /(\d+) (\d+) (\d+) (\d+) (\h+) '([\w\/ ]+)' (\d+) (\d+) (\d+) '(.+)' '(.+)' (\d+) (\d+) (\h+) (\h+) (\d+) (\d+) (\d+) (\d+) (\d+)/.freeze
      STAT_FORMAT = "%a %b %B %d %f '%F' %g %h %i '%m' '%n' %o %s %t %T %u %W %X %Y %Z"
      FIND_FORMAT = ""

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
      S_IRUSR = 0b100000000
      S_IWUSR = 0b010000000
      S_IXUSR = 0b001000000
      S_IRGRP = 0b000100000
      S_IWGRP = 0b000010000
      S_IXGRP = 0b000001000
      S_IROTH = 0b000000100
      S_IWOTH = 0b000000010
      S_IXOTH = 0b000000001

      #       pry(main)> a.match /(\d+) (\d+) (\d+) (\d+) (\h+) '([\w
      # ]+)' (\h+) (\h+) (\d+) (\w+) (\d+) (\d+) '(.+)' '(.+)' (\d+) (\d+) (\d+) (\d+) (\d+) (\w+) (\d+) (\d+) (\d+) (\d+)/
      # => #<MatchData
      #  "644 427272 512 2050 81a4 'regular file' 100 users 1 2623327 '/' '/home/arthur/test' 4096 218759168 0 0 1000 arthur 0 1340357826 1340357846 1340357846"
      #  1:"644"
      #  2:"427272"
      #  3:"512"
      #  4:"2050"
      #  5:"81a4"
      #  6:"regular file"
      #  7:"100"
      #  8:"users"
      #  9:"1"
      #  10:"2623327"
      #  11:"/"
      #  12:"/home/arthur/test"
      #  13:"4096"
      #  14:"218759168"
      #  15:"0"
      #  16:"0"
      #  18:"arthur"
      #  19:"0"
      #  20:"1340357826"
      #  21:"1340357846"
      #  22:"1340357846">

 # 1:"644"
 # 2:"427272"
 # 3:"512"
 # 4:"2050"
 # 5:"81a4"
 # 6:"regular file"
 # 7:"100"
 # 8:"1"
 # 9:"2623327"
 # 10:"/"
 # 11:"/home/arthur/test"
 # 12:"4096"
 # 13:"218759168"
 # 14:"0"
 # 15:"0"
 # 16:"1000"
 # 17:"0"
 # 18:"1340357826"
 # 19:"1340357846"
 # 20:"1340357846">

      class << self

        ##
        # Parses a given string for file stat information.
        #
        # @param [String] string The String to be parsed.
        # @return [EM::File::Stat] The file stat object.
        def parse str
          if m = str.match(STAT_REGEX)
            ftype = case m[6]
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
            EM::File::Stat.new path: m[11],
                               mountpoint: m[10],
                               atime: Time.at(Integer(m[18], 10)),
                               blksize: Integer(m[3], 10),
                               blocks: Integer(m[2], 10),
                               ctime: Time.at(Integer(m[20], 10)),
                               dev: Integer(m[4], 10),
                               dev_major: Integer(m[14], 8),
                               dev_minor: Integer(m[15], 8),
                               ftype: ftype,
                               gid: Integer(m[7], 10),
                               ino: Integer(m[9], 10),
                               mode: Integer(m[1], 8),
                               mtime: Time.at(Integer(m[19], 10)),
                               nlink: Integer(m[8], 10),
                               size: Integer(m[13], 10),
                               uid: Integer(m[16], 10)
          else
            raise "Unable to parse stat string: #{str}"
          end
        end
      end

      def initialize val = {}
        @path = val[:path]
        @mountpoint = val[:mountpoint]
        @atime = val[:atime]
        @blksize = val[:blksize]
        @blocks = val[:blocks]
        @ctime = val[:ctime]
        @dev = val[:dev]
        @dev_major = val[:dev_major]
        @dev_minor = val[:dev_minor]
        @ftype = val[:ftype]
        @gid = val[:gid]
        @ino = val[:ino]
        @mode = val[:mode]
        @mtime = val[:mtime]
        @nlink = val[:nlink]
        @size = val[:size]
        @uid = val[:uid]
      end

      #atime
      def atime
        @atime
      end

      #blksize
      def blksize
        @blksize
      end

      #blockdev?
      def blockdev?
        ftype^S_IFBLK == 0
      end

      #blocks
      def blocks
        @blocks
      end

      #chardev?
      def chardev?
        ftype^S_IFCHR == 0
      end

      #ctime
      def ctime
        @ctime
      end

      #dev
      def dev
        @dev
      end

      #dev_major
      def dev_major
        @dev_major
      end

      #dev_minor
      def dev_minor
        @dev_minor
      end

      #directory?
      def directory?
        ftype^S_IFDIR == 0
      end

      #executable?
      def executable?
        return true if Process::UID.rid == 0
        return @mode & S_IXUSR != 0 if rowned?
        return @mode & S_IXGRP != 0 if rgrpowned?
        @mode & S_IXOTH != 0
      end

      #executable_real?
      def executable_real?
        return true if Process::UID.rid == 0
        return @mode & S_IXUSR != 0 if rowned?
        return @mode & S_IXGRP != 0 if rgrpowned?
        @mode & S_IXOTH != 0
      end

      #file?
      def file?
        ftype^S_IFREG == 0
      end

      #ftype
      def ftype
        @ftype
      end

      #gid
      def gid
        @gid
      end

      #grpowned?
      def grpowned?
        gid == Process::GID.eid
      end

      def rgrpowned?
        gid == Process::GID.rid
      end

      #ino
      def ino
        @ino
      end

      #mode
      def mode
        @mode.to_s(8)
      end

      #mtime
      def mtime
        @mtime
      end

      #nlink
      def nlink
        @nlink
      end

      #owned?
      def owned?
        uid == Process::UID.eid
      end

      def rowned?
        uid == Process::UID.rid
      end

      #pipe?
      def pipe?
        ftype^S_IFIFO == 0
      end

      #readable?
      def readable?
        return true if Process::UID.eid == 0
        return @mode & S_IRUSR != 0 if owned?
        return @mode & S_IRGRP != 0 if grpowned?
        @mode & S_IROTH != 0
      end

      #readable_real?
      def readable_real?
        return true if Process::UID.rid == 0
        return @mode & S_IRUSR != 0 if rowned?
        return @mode & S_IRGRP != 0 if rgrpowned?
        @mode & S_IROTH != 0
      end

      #setgid?
      def setgid?
        @setgid
      end

      #setuid?
      def setuid?
        @setuid
      end

      #size
      def size
        @size
      end

      #socket?
      def socket?
        ftype^S_IFSOCK == 0
      end

      #sticky?
      def sticky?

      end

      #symlink?
      def symlink?
        ftype^S_IFLNK == 0
      end

      #uid
      def uid
        @uid
      end

      #world_readable?
      def world_readable?
        if @mode & S_IROTH == S_IROTH
          @mode
        end
      end

      #world_writable?
      def world_writable?
        if @mode & S_IWOTH == S_IWOTH
          @mode
        end
      end

      #writable?
      def writable?
        return true if Process::UID.rid == 0
        return @mode & S_IWUSR != 0 if owned?
        return @mode & S_IWGRP != 0 if grpowned?
        @mode & S_IWOTH != 0
      end

      ##
      #
      def writable_real?
        return true if Process::UID.rid == 0
        return @mode & S_IWUSR != 0 if rowned?
        return @mode & S_IWGRP != 0 if rgrpowned?
        @mode & S_IWOTH != 0
      end

      #zero?
      def zero?
        @size == 0
      end

    end
  end
end
