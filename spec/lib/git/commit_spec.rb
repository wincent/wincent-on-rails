require 'spec_helper'

describe Git::Commit do
  let(:repo)  { Git::Repo.new scratch_repo }
  let(:ref)   { repo.head }

  describe '::log' do
    let(:commits) { Git::Commit.log ref }

    it 'returns an array of Commit objects' do
      expect(commits).to be_kind_of(Array)
      expect(commits.all? { |commit| commit.kind_of?(Git::Commit) }).to eq(true)
      expect(commits).not_to be_empty
    end

    context 'empty repo' do
      it 'returns an empty array' do
        pending # repo.head fails because of git show-ref --head exit status 1
        repo = Git::Repo.new empty_repo
        expect(repo.head.log).to eq([])
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
      expect(@commit).to be_kind_of(Git::Commit)
    end

    specify 'returned commit matches requested SHA-1' do
      expect(@commit.commit).to eq(@head)
    end

    specify 'returned commit has a reference to its repo' do
      expect(@commit.repo).to eq(@repo)
    end

    specify 'returned commit specifies no associted ref' do
      expect(@commit.ref).to eq(nil)
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

    context 'abbreviated commit hash' do
      let(:abbrev) { @head[0, 8] }
      let(:commit) { Git::Commit.commit_with_hash abbrev, @repo }

      it 'stores the full 40-character hash' do
        expect(abbrev.length).to eq(8)
        expect(commit.commit.length).to eq(40)
        expect(commit.commit).to eq(@head)
      end
    end

    context 'mixed case commit hash' do
      let(:sha1) { @head.upcase }
      let(:commit) { Git::Commit.commit_with_hash sha1, @repo }

      it 'stores a downcased hash' do
        expect(sha1).to match(/[A-F]/) # sanity check first
        expect(commit.commit).to eq(commit.commit.downcase)
      end
    end
  end

  describe 'attributes' do
    let(:commit) { Git::Commit.log(ref).first }

    describe '#commit' do
      it 'is a 40-character SHA-1 hash' do
        expect(commit.commit).to match(/\A[a-f0-9]{40}\z/)
      end
    end

    describe '#tree' do
      it 'is a 40-character SHA-1 hash' do
        expect(commit.tree).to match(/\A[a-f0-9]{40}\z/)
      end
    end

    describe '#parents' do
      it 'returns an array' do
        expect(commit.parents).to be_kind_of(Array)
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
          expect(parents.count).to eq(1)
          expect(parents.first).to match(/\A[a-f0-9]{40}\z/)
        end
      end

      context 'root commit' do
        it 'returns an empty array' do
          expect(Git::Commit.log(ref).last.parents).to eq([])
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
          expect(parents.count).to eq(2)
          expect(parents.all? { |parent| parent.match(/\A[a-f0-9]{40}\z/) }).to eq(true)
        end
      end
    end

    describe '#author' do
      it 'returns a Git::Author instance' do
        expect(commit.author).to be_kind_of(Git::Author)
      end

      it 'has a name' do
        expect(commit.author.name).to be_kind_of(String)
        expect(commit.author.name.length).to be > 0
      end

      it 'has an email' do
        expect(commit.author.email).to match(/.+@.+/)
      end

      it 'has a timestamp' do
        expect(commit.author.time).to be_kind_of(Time)
      end
    end

    describe '#committer' do
      it 'returns a Git::Committer instance' do
        expect(commit.committer).to be_kind_of(Git::Committer)
      end

      it 'has a name' do
        expect(commit.committer.name).to be_kind_of(String)
        expect(commit.committer.name.length).to be > 0
      end

      it 'has an email' do
        expect(commit.committer.email).to match(/.+@.+/)
      end

      it 'has a timestamp' do
        expect(commit.committer.time).to be_kind_of(Time)
      end
    end

    describe '#encoding' do
      context 'no encoding' do
        it 'is nil' do
          expect(commit.encoding).to be_nil
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
          expect(encoding).to eq('ISO-8859-1')
        end
      end
    end

    describe '#message' do
      it 'returns the commit log message' do
        expect(commit.message).to eq('initial import')
      end

      context 'with Signed-off-by: line' do
        it 'includes the Signed-off-by: line' do
          Dir.chdir repo.path do
            `echo "foo" >> file`
            `git add file`
            `git commit -s -m "more foo"`
          end
          message = Git::Commit.log(ref).first.message
          expect(message).to match(/more foo\n\n/)
          expect(message).to match(/Signed-off-by: .+\.+/)
        end
      end
    end

    describe '#subject' do
      context 'a single-line commit log message' do
        it 'returns the entire commit log message' do
          expect(commit.subject).to eq('initial import')
        end
      end

      context 'a multi-line commit log message' do
        it 'returns the first line of the commit log message' do
          Dir.chdir repo.path do
            `echo "foo" >> file`
            `git add file`
            `git commit -m "invasive changes\n\nbut necessary ones"`
          end
          expect(commit.subject).to eq('invasive changes')
        end
      end
    end

    describe '#ref' do
      it 'returns the associated reference' do
        expect(commit.ref).to eq(ref)
      end

      context 'no associated reference' do
        it 'returns nil' do
          commit = Git::Commit.commit_with_hash repo.head.sha1, repo
          expect(commit.ref).to be_nil
        end
      end
    end

    describe '#repo' do
      it 'returns the associated repo' do
        expect(commit.repo).to eq(repo)
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
      expect(diff).to be_kind_of(Array)
    end

    describe 'changes array' do
      it 'contains one hash per changed file' do
        expect(diff.length).to eq(1)
        expect(diff.first).to be_kind_of(Hash)
      end

      describe 'changed file hash' do
        let(:hash) { diff.first }

        specify 'added attribute indicates number of added lines' do
          expect(hash[:added]).to eq(1)
        end

        specify 'deleted attribute indicates number of deleted lines' do
          expect(hash[:deleted]).to eq(0)
        end

        specify 'path attribute indicates changed path' do
          expect(hash[:path]).to eq('file')
        end

        specify 'hunks attribute is an array of changed hunks' do
          expect(hash[:hunks]).to be_kind_of(Array)
        end

        describe 'hunks array' do
          let(:hunks) { hash[:hunks] }

          it 'contains one hunk object per changed hunk' do
            expect(hunks.length).to eq(1)
            expect(hunks.first).to be_kind_of(Git::Hunk)
          end

          describe 'hunk' do
            let(:hunk) { hunks.first }

            it 'records the preimage start' do
              expect(hunk.preimage_start).to eq(1)
            end

            it 'records the preimage length' do
              expect(hunk.preimage_length).to eq(1)
            end

            it 'records the postimage start' do
              expect(hunk.postimage_start).to eq(1)
            end

            it 'records the postimage length' do
              expect(hunk.postimage_length).to eq(2)
            end

            it 'records an array of lines' do
              expect(hunk.lines).to be_kind_of(Array)
            end

            describe 'lines array' do
              let(:lines) { hunk.lines }

              it 'contains a context line' do
                expect(lines.first).to be_kind_of(Git::Hunk::Line)
                expect(lines.first.kind).to eq(:context)
              end

              describe 'context line' do
                let(:line) { lines.first }

                it 'records its preimage line number' do
                  expect(line.preimage_line_number).to eq(1)
                end

                it 'records its postimage line number' do
                  expect(line.postimage_line_number).to eq(1)
                end

                it 'records an array of line segments' do
                  expect(line.segments).to eq([[:context, 'foo']])
                end
              end

              it 'contains an addition line' do
                expect(lines[1]).to be_kind_of(Git::Hunk::Line)
                expect(lines[1].kind).to eq(:added)
              end

              describe 'addition line' do
                let(:line) { lines[1] }

                it 'has a nil preimage line number' do
                  expect(line.preimage_line_number).to be_nil
                end

                it 'records its postimage line number' do
                  expect(line.postimage_line_number).to eq(2)
                end

                it 'records an array of line segments' do
                  expect(line.segments).to eq([[:added, 'stuff']])
                end
              end
            end
          end
        end
      end
    end

    describe 'regressions' do
      it 'handles commits which only change mode (1 file)' do
        Dir.chdir repo.path do
          `chmod +x file`
          `git add file`
          `git commit -m "mode change"`
        end

        expect do
          # was causing:
          #   NoMethodError: private method `chomp' called for nil:NilClass
          diff
        end.to_not raise_error
      end

      it 'handles commits which only change mode (2 files)' do
        Dir.chdir repo.path do
          `echo foo > file2`
          `git add file2`
          `git commit -m "adding another"`
          `chmod +x file file2`
          `git add file file2`
          `git commit -m "mode change"`
        end

        expect do
          # was causing:
          #   Git::Commit::MalformedDiffError: malformed diff output for line:
          #   diff --git a/file2 b/file2
          diff
        end.to_not raise_error
      end
    end

    # TODO: test root commit, merge commit etc
    # file creation, file deletion
    # removal within a line
    # addition within a line
    # change within a line
  end
end
