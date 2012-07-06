require 'spec_helper'

describe EM::File::Stat do
  describe '.parse' do
    context 'parsed stat' do
      subject do
        EM::File::Stat.parse "644 2050 'regular file' 100 1 2623327 '/home/arthur/test' 218759168 1000 1340357826 1340357846 1340357846"
      end

      its(:atime) { should == Time.at(1340357826) }
      its(:blockdev?) { should == false }
      its(:chardev?) { should == false }
      its(:ctime) { should == Time.at(1340357846) }
      its(:dev) { should == 2050 }
      its(:directory?) { should == false }
      its(:executable?) { should == false }
      its(:executable_real?) { should == false }
      its(:file?) { should == true }
      its(:ftype) { should == EM::File::Stat::S_IFREG }
      its(:gid) { should == 100 }
      its(:grpowned?) { should == true }
      its(:ino) { should == 2623327 }
      its(:mode) { should == '644' }
      its(:mtime) { should == Time.at(1340357846) }
      its(:nlink) { should == 1 }
      its(:owned?) { should == true }
      its(:pipe?) { should == false }
      its(:readable?) { should == true }
      its(:readable_real?) { should == true }
      its(:size) { should == 218759168 }
      its(:socket?) { should == false }
      its(:symlink?) { should == false }
      its(:uid) { should == 1000 }
      its(:world_readable?) { should == 420 }
      its(:world_writable?) { should == nil }
      its(:writable?) { should == true }
      its(:writable_real?) { should == true }
      its(:zero?) { should == false }
    end
  end
end
