require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'issues/_issues' do
  before do
    # needed for sortable_header_cell because it calls url_for
    controller.params[:controller] = 'issues'
    controller.params[:action] = 'index'
    @issues = Array.new(4) { Issue.make! }
  end

  it 'shows pagination at top and bottom of the page' do
    render
    rendered.should have_selector('div.pagination', :count => 2)
  end

  it 'has a sortable header cell for the "id" column' do
    render
    rendered.should have_selector('th a', :content => '#') do |link|
      link.attribute('href').value.should match('sort=id')
    end
  end

  it 'has a sortable header cell for the "summary" column' do
    render
    rendered.should have_selector('th a', :content => 'Summary') do |link|
      link.attribute('href').value.should match('sort=summary')
    end
  end

  it 'has a sortable header cell for the "product" column' do
    render
    rendered.should have_selector('th a', :content => 'Product') do |link|
      link.attribute('href').value.should match('sort=product_id')
    end
  end

  it 'has a sortable header cell for the "status" column' do
    render
    rendered.should have_selector('th a', :content => 'Status') do |link|
      link.attribute('href').value.should match('sort=status')
    end
  end

  it 'has a sortable header cell for the "kind" column' do
    render
    rendered.should have_selector('th a', :content => 'Kind') do |link|
      link.attribute('href').value.should match('sort=kind')
    end
  end

  it 'has a sortable header cell for the "when" column' do
    render
    rendered.should have_selector('th a', :content => 'When') do |link|
      link.attribute('href').value.should match('sort=updated_at')
    end
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

  it 'employs alternating table rows' do
    render
    rendered.should have_selector('tr.odd', :count => 2)
    rendered.should have_selector('tr.even', :count => 2)
  end
end
