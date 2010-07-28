require 'git'

module Git
  class Repo
    attr_reader :path

    def initialize path
      raise ArgumentError if path.nil?
      raise Errno::ENOENT unless File.exist?(path)
      @path = path
      validate_path
    end

  private

    def git *params
      Dir.chdir @path do
        return Wopen3.system 'git', *params
      end
    end

    def validate_path
      result = git 'rev-parse', '--git-dir'
      raise Git::NoRepositoryError unless result.status == 0
    end
  end # class Repo
end # module Git
