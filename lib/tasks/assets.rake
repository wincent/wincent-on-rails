require 'digest/sha1'
require 'fileutils'
require 'pathname'
require 'shellwords'

namespace :assets do
  namespace :deploy do
    desc 'Check if precompiled assets are available for ${REF-HEAD}'
    task check: :environment do
      exit(precompiled? ? 0 : 1)
    end

    desc 'Precompile and store assets for deployment ${REF-HEAD}'
    task store: :environment do
      if precompiled?
        puts 'assets already precompiled; doing nothing'
      else
        purge_scratch_repo
        prepare_scratch_repo
        set_up_upstream_remote
        set_up_config_files
        precompile
        commit
        push
      end
    end

    desc 'Print stored asset tag for use in deployment ${REF-HEAD}'
    task print_tag: :environment do
      puts tag # used by `script/deploy`
    end

    def run!(command)
      `#{command}`.tap do |result|
        raise "#{command} failed" unless $?.success?
      end
    end

    def assets_scratch_repo
      Rails.root + 'tmp/assets'
    end

    def purge_scratch_repo
      puts 'Removing scratch repo'
      FileUtils.rm_rf(assets_scratch_repo)
    end

    def prepare_scratch_repo
      Dir.chdir(Rails.root) do
        dest = assets_scratch_repo.relative_path_from(Rails.root)
        puts 'Cloning scratch repo'
        run! [
          "git clone -q . #{Shellwords.shellescape(dest)}",
          "cd #{Shellwords.shellescape(dest)}",
          "git checkout -q --detach #{Shellwords.shellescape(ref)}",
        ].join(' && ')
      end
    end

    def set_up_upstream_remote
      Dir.chdir(assets_scratch_repo) do
        run! 'git remote add upstream git.wincent.com:/pub/git/private/wincent.com.git'
      end
    end

    def set_up_config_files
      Dir.chdir(assets_scratch_repo) do
        %w[app_config database].each do |file|
          FileUtils.cp "config/#{file}.yml.sample", "config/#{file}.yml"
        end
      end
    end

    def precompile
      Dir.chdir(assets_scratch_repo) do
        # we want a stable manifest digest, otherwise Sprockets will pick a
        # (basically) random manifest each time:
        #  https://github.com/sstephenson/sprockets/blob/eb84c414b76850af9b51bc495a52fb15d6ad24e3/lib/sprockets/manifest.rb#L46
        run! 'echo "{}" > public/assets/manifest-1bbe9a59b91db51e3d8fca89661cbfab.json'
        run! 'rake RAILS_ENV=production assets:precompile'
      end
    end

    def commit
      Dir.chdir(assets_scratch_repo) do
        tree = run! [
          'rm public/assets/.gitignore',
          'git add --all public/assets',
          'git write-tree --prefix public/assets',
        ].join(' && ').chomp
        message = "Asset build for #{ref_as_hash}"
        run! "git tag -a -m #{Shellwords.shellescape(message)} #{Shellwords.shellescape(tag)} #{tree}"
      end
    end

    def push
      Dir.chdir(assets_scratch_repo) do
        run! "git push upstream tag #{Shellwords.shellescape(tag)}"
      end
    end

    def ref
      ENV['REF'] || 'HEAD'
    end

    def ref_as_hash
      run!("git rev-parse #{Shellwords.shellescape(ref)}").chomp
    end

    def assets_paths
      Wincent::Application.config.assets.paths.map { |path| Pathname.new(path) }
    end

    def fingerprintable_paths
      assets_paths.map { |path| path.relative_path_from(Rails.root) }
    end

    def fingerprint
      @fingerprint ||= begin
        paths     = Shellwords.shelljoin(fingerprintable_paths)
        command   = "git ls-tree #{Shellwords.shellescape(ref)} #{paths}"
        path_info = Dir.chdir(Rails.root) { run!(command) }
        Digest::SHA1.hexdigest(path_info)
      end
    end

    def tag
      "assets-#{fingerprint}"
    end

    def precompiled?
      Dir.chdir(Rails.root) do
        # do we have the assets locally? failing that, can we fetch them?
        `git rev-parse -q --verify #{tag} &> /dev/null ||
         git fetch -q origin tag #{tag} &> /dev/null`

        $?.success?
      end
    end
  end
end
