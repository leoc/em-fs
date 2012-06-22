require 'spec_helper'

describe EM::DirListing do
  describe '#each' do
    it 'should execute a block for each directory entry stat'
  end

  describe '#each_entry' do
    it 'should execute a block with filename for each entry'
  end

  describe '#each_path' do
    it 'should execute a block with full path for each entry'
  end
end
