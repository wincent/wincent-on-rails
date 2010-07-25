namespace :static do
  desc 'Generate static HTML files in public/'
  task :generate do
    sh "script/static '403 forbidden'             app/views/public/403.html.haml          public/403.html"
    sh "script/static '404 not found'             app/views/public/404.html.haml          public/404.html"
    sh "script/static '422 rejected'              app/views/public/422.html.haml          public/422.html"
    sh "script/static '500 internal server error' app/views/public/500.html.haml          public/500.html"
    sh "script/static 'maintenance'               app/views/public/maintenance.html.haml  public/maintenance.html"
  end
end
