require 'spec_helper'

describe ReposHelper do
  describe '#commit_abbrev' do
    it 'returns the first 16 characters of the hash' do
      commit_abbrev('1234abcd1234abcd999999999999999999999999').
        should == '1234abcd1234abcd'
    end
  end

  describe '#commit_author_time' do
    pending
  end

  describe '#commit_committer_time' do
    pending
  end
end
