require 'git'
require 'pathname'

module Git
  class Repo
    attr_reader :path

    def initialize path
      raise ArgumentError if path.nil?
      @path = Pathname.new path
      raise Errno::ENOENT unless @path.exist?
      raise Git::NoRepositoryError if git_dir.nil?
    end

    def git *params
      Dir.chdir @path do
        return Wopen3.system 'git', *params
      end
    end

    def git_dir
      if @git_dir.nil?
        result = git 'rev-parse', '--git-dir'
        @git_dir = @path + result.stdout.chomp if result.status == 0
      end
      @git_dir
    end
  end # class Repo
end # module Git
