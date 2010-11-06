module Git
  class Blob
    attr_reader :commitish, :content, :path, :repo

    def initialize commitish, path, repo
      @commitish  = commitish # must be reachable
      @path       = path
      @repo       = repo
    end
  end # class Blob
end # module Git
