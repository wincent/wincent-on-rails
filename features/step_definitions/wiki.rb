Given /^no articles in the wiki$/ do
  Article.destroy_all
end

Given /^an article titled "(.*)"$/ do |title|
  create_article :title => title
end
