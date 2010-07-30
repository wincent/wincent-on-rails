require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Git::Ref do
  before do
    @repo = Git::Repo.new(scratch_repo)
  end

  describe '::head' do
    before do
      @ref = Git::Ref.head @repo
    end

    it 'returns a Ref instance' do
      @ref.should be_kind_of(Git::Ref)
    end

    specify 'returned objects matches HEAD' do
      @ref.name.should == 'HEAD'
    end
  end
end
