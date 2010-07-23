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
    visit edit_post_path(Post.make!)
    fill_in 'Title', :with => '' # invalid!
    fill_in 'Permalink', :with => 'new-permalink'
    click_button 'Update Post'
    page.should have_content("Title can't be blank")

    fill_in 'Title', :with => 'Valid title'
    click_button 'Update Post'
    page.should have_content('Valid title')
  end

  scenario 'editing an article' do
    visit edit_article_path(Article.make!)
    fill_in 'Title', :with => '' # invalid!
    click_button 'Update Article'
    page.should have_content("Title can't be blank")

    fill_in 'Title', :with => 'Valid title'
    click_button 'Update Article'
    page.should have_content('Valid title')
  end

  scenario 'editing a link', :js => true do
    visit edit_link_path(Link.make!)
    fill_in 'Permalink', :with => '_'
    click_button 'Update Link'
    page.should have_content('Permalink may only contain')

    fill_in 'Permalink', :with => 'foo'
    click_button 'Update Link'
    page.should have_content('Successfully updated')
  end

  scenario 'editing an email' do
    visit edit_user_email_path(@user, @user.emails.first)
    fill_in 'Address', :with => '' # invalid!
    click_button 'Update Email'
    page.should have_content("Address can't be blank")

    fill_in 'Address', :with => 'valid@example.com'
    click_button 'Update Email'
    page.should have_content('Public profile') # NOTE: this will change
  end

  scenario 'editing a forum', :js => true do
    visit edit_forum_path(Forum.make!)
    fill_in 'Permalink', :with => '_' # invalid!
    click_button 'Update Forum'
    page.should have_content('Permalink must contain')

    fill_in 'Permalink', :with => 'foo'
    click_button 'Update Forum'
    page.should have_content('Successfully updated')
  end

  scenario 'editing a page', :js => true do
    product = Product.make!
    visit edit_product_page_path(product, Page.make!(:product => product))
    fill_in 'Permalink', :with => '' # invalid!
    click_button 'Update Page'
    page.should have_content("Permalink can't be blank")

    fill_in 'Permalink', :with => 'foo'
    click_button 'Update Page'
    page.should have_content('Successfully updated')
  end

  scenario 'editing a product', :js => true do
    visit edit_product_path(Product.make!)
    fill_in 'Permalink', :with => '' # invalid!
    click_button 'Update Product'
    page.should have_content("Permalink can't be blank")

    fill_in 'Permalink', :with => 'foo'
    click_button 'Update Product'
    page.should have_content('Successfully updated')
  end

  scenario 'editing a tag' do
    visit edit_tag_path(Tag.make!)
    fill_in 'Name', :with => '' # invalid!
    click_button 'Update Tag'
    page.should have_content("Name can't be blank")

    fill_in 'Name', :with => 'foobar'
    click_button 'Update Tag'
    page.should have_content('foobar')
  end
end
