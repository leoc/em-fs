# -*- coding: utf-8 -*-
require 'spec_helper'

describe EM::Dir do
  describe '.[]' do
    it 'should create a `DirListing` instance'
  end

  describe '#each' do
    context 'with depth = 0' do
      it 'should execute the block for each entry'
    end

    context 'with depth = 1' do
      it 'should execute the block for each entry and directory´s entry'
    end

    context 'with depth = :inf' do
      it 'should execute the block for each entry in tree'
    end
  end

  describe '#each_entry' do
    it 'should execute a block with entry for each entry'
    it 'should use depth = 0 by default'
  end

  describe '#each_path' do
    it 'should execute a block with full path for each entry'
    it 'should use depth = :inf by default'
  end
end
