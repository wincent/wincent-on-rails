namespace :spec do
  desc 'Run all low-level code examples (not acceptance specs)'
  task :unit => [:requests, :models, :controllers, :views, :helpers,
    :mailers, :lib, :routing]

  namespace :unit do
    desc 'Run all low-level code examples under rcov'
    RSpec::Core::RakeTask.new :rcov do |t|
      t.rcov = true
      t.rcov_path = 'bin/rcov'

      # skip:
      #   acceptance (runs separate process)
      #   meta (code quality only)
      #   public (static files)
      t.pattern = 'spec/{controllers,helpers,mailers,models,lib,routing,views}/**/*_spec.rb'

      exclude = %w(
        /Library/*
        .bundle/*
        config/*
        spec/spec_helper.rb
        spec/support/*
        vendor/*
      ).join(',')

      t.rcov_opts = "--exclude #{exclude}"
    end
  end
end
