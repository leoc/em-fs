# -*- coding: utf-8 -*-
require 'spec_helper'

describe EM::Dir do
  describe '.[]' do
    it 'should create a `EM::Dir::Glob` instance' do
      EM::Dir['./**/*.rb'].should be_a EM::Dir::Glob
    end
  end

  describe '.glob' do
    it 'should create a `EM::Dir::Glob` instance' do
      EM::Dir['./**/*.rb'].should be_a EM::Dir::Glob
    end
  end
end
