static_templates = Dir.glob('app/views/public/*.html.haml')
static_products = static_templates.map do |template|
  template.match %r{app/views/(public/.*\.html)\.haml}
  $~[1]
end

static_templates.each_with_index do |template, idx|
  file static_products[idx] => [template, 'app/views/layouts/static.haml'] do |t|
    sh "script/static #{template} #{t.name}"
  end
end

namespace :static do
  desc 'Generate static HTML files in public/'
  task :generate => static_products
end
