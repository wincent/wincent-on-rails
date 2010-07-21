require File.expand_path('../acceptance_helper', File.dirname(__FILE__))

# https://wincent.com/issues/1616
feature 'validation errors combined with permalink modifications' do

  background do
    @user = User.make! :superuser => true
    log_in_as @user
  end

  scenario 'editing a user' do
    visit edit_user_path(@user)
    fill_in 'Display name', :with => 'x'
    click_button 'Update User'
    page.should have_content('Display name is too short')

    fill_in 'Display name', :with => 'Longer Name'
    click_button 'Update User'
    page.should have_content('Longer Name Public profile')
  end

  scenario 'editing a post' do
    post = Post.make!
    visit edit_post_path(post)
    fill_in 'Title', :with => '' # invalid!
    fill_in 'Permalink', :with => 'new-permalink'
    click_button 'Update Post'
    page.should have_content("Title can't be blank")

    fill_in 'Title', :with => 'Valid title'
    click_button 'Update Post'
    page.should have_content('Valid title')
  end

  scenario 'editing an article'
  scenario 'editing a link'
  scenario 'editing an email'
  scenario 'editing a forum'
  scenario 'editing a page'
  scenario 'editing a product'
  scenario 'editing a tag'
end
