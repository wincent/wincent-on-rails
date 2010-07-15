require File.expand_path('../../../spec_helper', File.dirname(__FILE__))

describe 'admin/tags/index' do
  before do
    # needed for sortable_header_cell because it calls url_for
    controller.params[:controller] = 'admin/tags'
    controller.params[:action] = 'index'
    @tags = [Tag.make!]
  end

  describe 'regressions' do
    it 'has a sortable header cell for the "name" column' do
      render
      rendered.should have_selector('th a', :content => 'Name') do |link|
        link.attribute('href').value.should match('sort=name')
      end
    end

    it 'has a sortable header cell for the "taggings count" column' do
      render
      rendered.should have_selector('th a', :content => 'Taggings count') do |link|
        link.attribute('href').value.should match('sort=taggings_count')
      end
    end
  end
end
