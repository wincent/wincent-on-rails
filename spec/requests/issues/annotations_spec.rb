require 'spec_helper'

feature 'annotations for changes to issue metadata' do
  scenario 'changing an issue summary' do
    issue = Issue.make! :summary => 'foo'
    log_in_as_admin
    visit edit_issue_path(issue)
    fill_in 'issue[summary]', :with => 'bar'
    click_button 'Update Issue'
    page.should have_content('Summary changed')
    page.should have_content('From: foo')
    page.should have_content('To: bar')
  end
end
