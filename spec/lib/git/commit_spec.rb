require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Git::Commit do
  let(:repo)  { Git::Repo.new scratch_repo }
  let(:ref)   { repo.head }

  describe '::log' do
    let(:commits) { Git::Commit.log ref }

    it 'returns an array of Commit objects' do
      commits.should be_kind_of(Array)
      commits.all? { |commit| commit.kind_of?(Git::Commit) }.should be_true
      commits.should_not be_empty
    end

    context 'empty repo' do
      it 'returns an empty array' do
        pending # repo.head fails because of git show-ref --head exit status 1
        repo = Git::Repo.new empty_repo
        repo.head.log.should == []
      end
    end
  end

  describe '::commit_with_hash' do
    before do
      @repo = Git::Repo.new scratch_repo
      Dir.chdir @repo.path do
        @head = `git rev-parse HEAD`.chomp
      end
      @commit = Git::Commit.commit_with_hash @head, @repo
    end

    it 'returns a commit object' do
      @commit.should be_kind_of(Git::Commit)
    end

    specify 'returned commit matches requested SHA-1' do
      @commit.commit.should == @head
    end

    specify 'returned commit has a reference to its repo' do
      @commit.repo.should == @repo
    end

    specify 'returned commit specifies no associted ref' do
      @commit.ref.should == nil
    end

    context 'unreachable commit' do
      it 'complains' do
        Dir.chdir @repo.path do
          `git commit --amend -m "new head, old head now unreachable"`
        end
        expect do
          Git::Commit.commit_with_hash @head, @repo
        end.to raise_error(Git::Commit::UnreachableCommitError)
      end
    end

    context 'non-existent commit' do
      it 'complains' do
        expect do
          Git::Commit.commit_with_hash '0' * 40, @repo
        end.to raise_error(Git::Commit::NoCommitError)
      end
    end
  end

  describe 'attributes' do
    let(:commit) { Git::Commit.log(ref).first }

    describe '#commit' do
      it 'is a 40-character SHA-1 hash' do
        commit.commit.should =~ /\A[a-f0-9]{40}\z/
      end
    end

    describe '#tree' do
      it 'is a 40-character SHA-1 hash' do
        commit.tree.should =~ /\A[a-f0-9]{40}\z/
      end
    end

    describe '#parents' do
      it 'returns an array' do
        commit.parents.should be_kind_of(Array)
      end

      context 'normal commit' do
        it 'returns a single SHA-1 hash' do
          Dir.chdir repo.path do
            # repo only has a root commit in it, so add another
            `echo 'secret' > sauce`
            `git add sauce`
            `git commit -m "add secret sauce"`
          end
          parents = Git::Commit.log(ref).first.parents
          parents.count.should == 1
          parents.first.should =~ /\A[a-f0-9]{40}\z/
        end
      end

      context 'root commit' do
        it 'returns an empty array' do
          Git::Commit.log(ref).last.parents.should == []
        end
      end

      context 'merge commit' do
        it 'returns multiple SHA-1 hashes' do
          Dir.chdir repo.path do
            `git checkout -b topic 2> /dev/null`
            `echo 'new' >> bar`
            `git add bar`
            `git commit -m "additions to bar"`
            `git checkout master 2> /dev/null`
            `echo 'new' >> baz`
            `git add baz`
            `git commit -m "additions to baz"`
            `git merge topic`
          end
          parents = Git::Commit.log(ref).first.parents
          parents.count.should == 2
          parents.all? { |parent| parent.match(/\A[a-f0-9]{40}\z/) }.should be_true
        end
      end
    end

    describe '#author' do
      it 'returns a Git::Author instance' do
        commit.author.should be_kind_of(Git::Author)
      end

      it 'has a name' do
        commit.author.name.should be_kind_of(String)
        commit.author.name.length.should > 0
      end

      it 'has an email' do
        commit.author.email.should =~ /.+@.+/
      end

      it 'has a timestamp' do
        commit.author.time.should be_kind_of(Time)
      end
    end

    describe '#committer' do
      it 'returns a Git::Committer instance' do
        commit.committer.should be_kind_of(Git::Committer)
      end

      it 'has a name' do
        commit.committer.name.should be_kind_of(String)
        commit.committer.name.length.should > 0
      end

      it 'has an email' do
        commit.committer.email.should =~ /.+@.+/
      end

      it 'has a timestamp' do
        commit.committer.time.should be_kind_of(Time)
      end
    end

    describe '#encoding' do
      context 'no encoding' do
        it 'is nil' do
          commit.encoding.should be_nil
        end
      end

      context 'with encoding' do
        it 'is an encoding string' do
          Dir.chdir repo.path do
            `git config i18n.commitencoding ISO-8859-1`
            `echo "crud" > crud`
            `git add crud`
            `git commit -m "encoded message"`
          end
          encoding = Git::Commit.log(ref).first.encoding
          encoding.should == 'ISO-8859-1'
        end
      end
    end

    describe '#message' do
      it 'returns the commit log message' do
        commit.message.should == "initial import"
      end

      context 'with Signed-off-by: line' do
        it 'includes the Signed-off-by: line' do
          Dir.chdir repo.path do
            `echo "foo" >> file`
            `git add file`
            `git commit -s -m "more foo"`
          end
          message = Git::Commit.log(ref).first.message
          message.should =~ /more foo\n\n/
          message.should =~ /Signed-off-by: .+\.+/
        end
      end
    end
  end
end
