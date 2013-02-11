require 'spec_helper'

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
      within('th a', text: 'Name') do |link|
        link[:href].should match('sort=name')
      end
    end

    it 'has a sortable header cell for the "taggings count" column' do
      render
      within('th a', text: 'Taggings count') do |link|
        link[:href].should match('sort=taggings_count')
      end
    end
  end
end
