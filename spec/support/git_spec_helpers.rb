require 'mkdtemp'
require 'pathname'

module GitSpecHelpers
  def scratch_repo
    Dir.mkdtemp do
      `git init`
      `echo "foo" > file`
      `git add file`
      `git commit -m "initial import"`
    end
  end

  def bare_scratch_repo
    bare = Dir.mkdtemp do
      `git init --bare`
    end

    # simplest way to get something into a bare repo is to push into it
    Dir.chdir scratch_repo do
      `git push #{bare} master 2> /dev/null`
    end
    bare
  end
end
