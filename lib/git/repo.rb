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
        @git_dir = @path + result.stdout.chomp if result.success?
      end
      @git_dir
    end

    def branches
      @branches ||= Branch.all self
    end

    def tags
      @tags ||= Tag.all self
    end

    # This method invokes the {#git} method and raises a {Git::CommandError}
    # if it returns a non-zero exit status.
    #
    # Mnemonic: "raise git"
    def r_git *params
      result = git *params
      raise Git::CommandError.new_with_result(result) unless result.success?
      result
    end
  end # class Repo
end # module Git
