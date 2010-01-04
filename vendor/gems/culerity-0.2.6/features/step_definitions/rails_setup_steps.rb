Given /^a Rails app$/ do
  FileUtils.chdir(@tmp_root) do
    `rails my_project`
  end
  @active_project_folder = File.expand_path(File.join(@tmp_root, "my_project"))
end

Given /^I copy the project generators into "([^\"]*)"$/ do |target_folder|
  in_project_folder do
    FileUtils.mkdir_p(target_folder)
  end
  `cp -rf #{File.dirname(__FILE__) + "/../../rails_generators/*"} #{File.join(@active_project_folder, target_folder)}`
end

When /^I add a feature file to test Rails index.html default file$/ do
  sample_feature = File.expand_path(File.dirname(__FILE__) + "/../fixtures/sample_feature")
  in_project_folder do
    `cp -rf #{sample_feature} features/sample.feature`
  end
end

When /^I setup the culerity javascript helpers$/ do
  `cp #{File.dirname(__FILE__) + "/../fixtures/jquery"} #{File.join(@active_project_folder, 'public', 'javascripts', 'jquery.js')}`
  in_project_folder do
    _index = File.read('public/index.html')
    File.open('public/index.html', 'w') do |f|
      f << _index.sub('</head>', '<script type="text/javascript" src="javascripts/jquery.js"></script><script type="text/javascript" src="javascripts/culerity.js"></script><script type="text/javascript">jQuery.noConflict();</script></head>')
    end
  end
end

After do
  in_project_folder do
    Given 'I invoke task "rake culerity:rails:stop"'
  end
end
