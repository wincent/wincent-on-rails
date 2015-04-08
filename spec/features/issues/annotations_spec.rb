require 'spec_helper'

feature 'annotations for changes to issue metadata' do
  scenario 'changing an issue summary' do
    issue = Issue.make! :summary => 'foo'
    log_in_as_admin
    visit edit_issue_path(issue)
    fill_in 'issue[summary]', :with => 'bar'
    click_button 'Update Issue'
    expect(page).to have_content('Summary changed')
    expect(page).to have_content('From: foo')
    expect(page).to have_content('To: bar')
  end
end
