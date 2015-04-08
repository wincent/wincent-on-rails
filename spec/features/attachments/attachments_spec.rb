require 'spec_helper'

feature 'attachment uploads' do
  scenario 'uploading a stand-alone attachment' do
    log_in_as_admin
    visit '/attachments/new'
    expect(page).to have_content('Upload')
  end
end
