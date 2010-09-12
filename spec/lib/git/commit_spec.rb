require 'spec_helper'

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
        commit.message.should == 'initial import'
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

    describe '#subject' do
      context 'a single-line commit log message' do
        it 'returns the entire commit log message' do
          commit.subject.should == 'initial import'
        end
      end

      context 'a multi-line commit log message' do
        it 'returns the first line of the commit log message' do
          Dir.chdir repo.path do
            `echo "foo" >> file`
            `git add file`
            `git commit -m "invasive changes\n\nbut necessary ones"`
          end
          commit.subject.should == 'invasive changes'
        end
      end
    end

    describe '#ref' do
      it 'returns the associated reference' do
        commit.ref.should == ref
      end

      context 'no associated reference' do
        it 'returns nil' do
          commit = Git::Commit.commit_with_hash repo.head.sha1, repo
          commit.ref.should be_nil
        end
      end
    end

    describe '#repo' do
      it 'returns the associated repo' do
        commit.repo.should == repo
      end
    end
  end

  describe '#diff' do
    before do
      Dir.chdir repo.path do
        `echo "stuff" >> file`
        `git add file`
        `git commit -m "new stuff"`
      end
    end

    let(:diff) { repo.head.commits.first.diff }

    it 'returns an array of changes' do
      diff.should be_kind_of(Array)
    end

    describe 'changes array' do
      it 'contains one hash per changed file' do
        diff.length.should == 1
        diff.first.should be_kind_of(Hash)
      end

      describe 'changed file hash' do
        let(:hash) { diff.first }

        specify 'added attribute indicates number of added lines' do
          hash[:added].should == 1
        end

        specify 'deleted attribute indicates number of deleted lines' do
          hash[:deleted].should == 0
        end

        specify 'path attribute indicates changed path' do
          hash[:path].should == 'file'
        end

        specify 'hunks attribute is an array of changed hunks' do
          hash[:hunks].should be_kind_of(Array)
        end

        describe 'hunks array' do
          let(:hunks) { hash[:hunks] }

          it 'contains one hunk object per changed hunk' do
            hunks.length.should == 1
            hunks.first.should be_kind_of(Git::Hunk)
          end

          describe 'hunk' do
            let(:hunk) { hunks.first }

            it 'records the preimage start' do
              hunk.preimage_start.should == 1
            end

            it 'records the preimage length' do
              hunk.preimage_length.should == 1
            end

            it 'records the postimage start' do
              hunk.postimage_start.should == 1
            end

            it 'records the postimage length' do
              hunk.postimage_length.should == 2
            end

            it 'records an array of lines' do
              hunk.lines.should be_kind_of(Array)
            end

            describe 'lines array' do
              let(:lines) { hunk.lines }

              it 'contains a context line' do
                lines.first.should be_kind_of(Git::Hunk::Line)
                lines.first.kind.should == :context
              end

              describe 'context line' do
                let(:line) { lines.first }

                it 'records its preimage line number' do
                  line.preimage_line_number.should == 1
                end

                it 'records its postimage line number' do
                  line.postimage_line_number.should == 1
                end

                it 'records an array of line segments' do
                  line.segments.should == [[:context, 'foo']]
                end
              end

              it 'contains an addition line' do
                lines[1].should be_kind_of(Git::Hunk::Line)
                lines[1].kind.should == :added
              end

              describe 'addition line' do
                let(:line) { lines[1] }

                it 'has a nil preimage line number' do
                  line.preimage_line_number.should be_nil
                end

                it 'records its postimage line number' do
                  line.postimage_line_number.should == 2
                end

                it 'records an array of line segments' do
                  line.segments.should == [[:added, 'stuff']]
                end
              end
            end
          end
        end
      end
    end

    # TODO: test root commit, merge commit etc
    # file creation, file deletion
    # removal within a line
    # addition within a line
    # change within a line
  end
end
