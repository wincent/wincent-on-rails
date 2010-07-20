require File.expand_path('../acceptance_helper', File.dirname(__FILE__))

# https://wincent.com/issues/1616
feature 'validation errors combined with permalink modifications' do

  scenario 'editing a user' do
    user = User.make!
    log_in_as user
    visit edit_user_path(user)
    fill_in 'Display name', :with => 'x'
    click_button 'Update User'
    page.should have_content('Display name is too short')

    fill_in 'Display name', :with => 'Longer Name'
    click_button 'Update User'
    page.should_not have_content('Edit user')
    page.should have_content('Public profile')
  end
end
