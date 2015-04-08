require 'spec_helper'

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
      expect(@error.message).to match(/Git::CommandError/)
    end

    it 'sets the message based on the command arguments' do
      expect(@error.message).to match(/git show-ref --crazy-argument/)
    end

    it 'sets the result' do
      expect(@error.result).not_to be_nil
    end

    describe '#result' do
      it 'responds to #stdout' do
        expect(@error.result.stdout).to be_kind_of(String)
      end

      it 'responds to #stderr' do
        expect(@error.result.stderr).to be_kind_of(String)
        expect(@error.result.stderr.length).to be > 0
      end

      it 'responds to #status' do
        expect(@error.result.status).not_to eq(0)
      end
    end
  end
end
