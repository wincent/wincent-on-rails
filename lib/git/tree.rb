module Git
  class Tree
    attr_reader :commitish, :entries, :path, :repo

    def initialize commitish, path, repo
      @commitish  = commitish # must be reachable
      @path       = path      # if nil, root path
      @repo       = repo
    end
  end # class Tree
end # module Git
