# useful regular expressions
DOUBLE_QUOTED_VALUE = %q{} # \. and anything else but "
SINGLE_QUOTED_VALUE = %q{}
REGULAR_EXPRESSION  = %q{}

#
# Primitives with one-to-one mapping to Capybara API
#

# navigation primitives
When /^I visit (.+)$/ do |path|
  visit path
end

# interaction primitives
When /^I click the "(.+)" link$/ do |link|
  click_link link
end

When /^I click the "(.+)" button$/ do |button|
  click_button button
end

When /^I fill in "(.+)" with "(.+)"$/ do |field, value|
  fill_in field, :with => value
end

# querying primitives
Then /^I should see "(.+)"$/ do |text|
  page.should have_content(text)
end

Then /^I should not see "(.+)"$/ do |text|
  page.should_not have_content(text)
end

Then /^the page should have CSS "(.+)"$/ do |css|
  page.should have_css(css)
end

Then /^the page should not have CSS "(.+)"$/ do |css|
  page.should_not have_css(css)
end

# scoped queries
Then /^I should see "(.+)" within "(.+)"$/ do |text, scope|
  within scope do
    page.should have_content(text)
  end
end

Then /^I should not see "(.+)" within "(.+)"$/ do |text, scope|
  within scope do
    page.should_not have_content(text)
  end
end

# aliases for primitive methods
When /^I go to (.+)$/ do |path|
  When "I visit #{path}"
end

When /^I press the "(.+)" button$/ do |button|
  When %Q{I press the "#{button}"}
end

When /^I press "(.+)"$/ do |button|
  When %Q{I press the "#{button}"}
end

# debugging steps
When /^I print an HTML dump of the DOM$/ do
  puts page.driver.send(:browser).text
end
