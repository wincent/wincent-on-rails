require 'mkdtemp'
require 'pathname'

module GitSpecHelpers
  def scratch_repo &block
    path = Dir.mkdtemp do
      `git init`
      `echo "foo" > file`
      `git add file`
      `git commit -m "initial import"`
    end
    Dir.chdir(path, &block) if block_given?
    path
  end

  def bare_scratch_repo &block
    bare = Dir.mkdtemp do
      `git init --bare`
    end

    # simplest way to get something into a bare repo is to push into it
    scratch_repo do
      `git push #{bare} master 2> /dev/null`
    end

    Dir.chdir(bare, &block) if block_given?
    bare
  end
end
