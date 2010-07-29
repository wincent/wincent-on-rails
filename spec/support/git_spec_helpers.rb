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
end
