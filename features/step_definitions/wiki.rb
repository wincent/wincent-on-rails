Given /^no articles in the wiki$/ do
  Article.destroy_all
end

When /^an article titled "(.*)" is added to the wiki$/ do |title|
  create_article :title => title
end

When /^I access the wiki index$/ do
  get '/wiki'
end
