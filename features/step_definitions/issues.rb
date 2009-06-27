Given /^an issue with summary "(.*)"$/ do |summary|
  create_issue :summary => summary
end

When /^I look at the issue with summary "(.*)"$/ do |summary|
  visit issue_path(Issue.find_by_summary!(summary))
end

When /^I edit the issue with summary "(.*)"$/ do |summary|
  visit edit_issue_path(Issue.find_by_summary!(summary))
end
