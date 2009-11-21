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
Then /^the page source should contain "(.+)"$/ do |text|
  page.should have_content(text)
end

Then /^the page source should match \/(.+)\/$/ do |regexp|
  regexp = Regexp.new regexp
  page.should have_content(regexp)
end

Then /^I should see "(.+)"$/ do |text|
  regexp = Regexp.new(Regexp.escape(text))
  HTML::FullSanitizer.new.sanitize(page.body).should match(regexp)
end

Then /^I should see \/(.+)\/$/ do |regexp|
  regexp = Regexp.new regexp
  HTML::FullSanitizer.new.sanitize(page.body).should match(regexp)
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
