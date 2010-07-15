require File.expand_path('../../../spec_helper', File.dirname(__FILE__))

describe 'admin/posts/index' do
  before do
    # needed for sortable_header_cell because it calls url_for
    controller.params[:controller] = 'admin/posts'
    controller.params[:action] = 'index'
    @posts = [Post.make!]
  end

  describe 'regressions' do
    it 'has a sortable header cell for the "title" column' do
      render
      rendered.should have_selector('th a', :content => 'Title') do |link|
        link.attribute('href').value.should match('sort=title')
      end
    end

    it 'has a sortable header cell for the "permalink" column' do
      render
      rendered.should have_selector('th a', :content => 'Permalink') do |link|
        link.attribute('href').value.should match('sort=permalink')
      end
    end

    it 'has a sortable header cell for the "when" column' do
      render
      rendered.should have_selector('th a', :content => 'When') do |link|
        link.attribute('href').value.should match('sort=created_at')
      end
    end
  end
end
