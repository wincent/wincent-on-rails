Given /^no articles in the wiki$/ do
  Article.destroy_all
end

When /^an article titled "(.*)" is added to the wiki$/ do |title|
  #create_article :title => title
  # unfortunately, can't use FixtureReplacement with Cucumber, it seems:
  # undefined local variable or method `validate' for #<Article:0x34031cc> (NameError)
  # vendor/plugins/fixture_replacement/lib/fixture_replacement/fixture_replacement_generator.rb:68:in `create_article'
  # bizarre because looks like an Article instance, doesn't it? and validate is defined
  # will have to try version 2, and if that doesn't work, make my own factory system
  Article.create :title => title, :body => 'body'
end

When /^I access the wiki index$/ do
  get '/wiki'
end
