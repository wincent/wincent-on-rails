require 'spec_helper'

describe 'issues/_issues' do
  before do
    # needed for sortable_header_cell because it calls url_for
    controller.params[:controller] = 'issues'
    controller.params[:action] = 'index'
    @issues = Array.new(4) { Issue.make! }
  end

  it 'shows the kind string for each issue'
  it 'links to a kind-scoped search from the kind string'
  it 'shows the id number for each issue'
  it 'shows the product for each issue'
  it 'links to a product-scoped search from the product string'
  it 'shows the summary for each issue'
  it 'likes to the issue "show" page from the summary text'
  it 'shows the status string for each issue'
  it 'links to a status-scope search from the status string'
  it 'shows the timestamp information for each issue'

  describe 'regressions' do
    it 'has a sortable header cell for the "id" column' do
      render
      within('th a', text: '#') do |link|
        link[:href].should match('sort=id')
      end
    end

    it 'has a sortable header cell for the "summary" column' do
      render
      within('th a', text: 'Summary') do |link|
        link[:href].should match('sort=summary')
      end
    end

    it 'has a sortable header cell for the "product" column' do
      render
      within('th a', text: 'Product') do |link|
        link[:href].should match('sort=product_id')
      end
    end

    it 'has a sortable header cell for the "status" column' do
      render
      within('th a', text: 'Status') do |link|
        link[:href].should match('sort=status')
      end
    end

    it 'has a sortable header cell for the "kind" column' do
      render
      within('th a', text: 'Kind') do |link|
        link[:href].should match('sort=kind')
      end
    end

    it 'has a sortable header cell for the "when" column' do
      render
      within('th a', text: 'When') do |link|
        link[:href].should match('sort=updated_at')
      end
    end
  end
end
