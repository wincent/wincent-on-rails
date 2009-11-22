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
