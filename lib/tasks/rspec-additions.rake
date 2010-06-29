namespace :spec do
  desc 'Run all low-level code examples (not acceptance specs)'
  task :unit => [:requests, :models, :controllers, :views, :helpers, :mailers, :lib, :routing]
end
