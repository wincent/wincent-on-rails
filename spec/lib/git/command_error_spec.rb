require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Git::CommandError do
  describe '::new_with_result' do
    before do
      # we use the Git::Repo class as a vehicle for testing this
      repo = Git::Repo.new scratch_repo
      @result = repo.git 'show-ref', '--crazy-argument'
      @error = Git::CommandError.new_with_result @result
    end

    it 'complains if passed a nil result' do
      expect do
        Git::CommandError.new_with_result nil
      end.to raise_error(NoMethodError)
    end

    it 'includes the class name in the message' do
      @error.message.should =~ /Git::CommandError/
    end

    it 'sets the message based on the command arguments' do
      @error.message.should =~ /git show-ref --crazy-argument/
    end

    it 'sets the result' do
      @error.result.should_not be_nil
    end

    describe '#result' do
      it 'responds to #stdout' do
        @error.result.stdout.should be_kind_of(String)
      end

      it 'responds to #stderr' do
        @error.result.stderr.should be_kind_of(String)
        @error.result.stderr.length.should > 0
      end

      it 'responds to #status' do
        @error.result.status.should_not == 0
      end
    end
  end
end
