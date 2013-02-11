require 'spec_helper'

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
      within('th a', text: 'Title') do |link|
        link[:href].should match('sort=title')
      end
    end

    it 'has a sortable header cell for the "permalink" column' do
      render
      within('th a', text: 'Permalink') do |link|
        link[:href].should match('sort=permalink')
      end
    end

    it 'has a sortable header cell for the "when" column' do
      render
      within('th a', text: 'When') do |link|
        link[:href].should match('sort=created_at')
      end
    end
  end
end
