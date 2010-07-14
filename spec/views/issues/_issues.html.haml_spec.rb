require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'issues/_issues' do
  before do
    stub(view).sortable_header_cell.with_any_args
    @issues = Array.new(4) { Issue.make! }
  end

  it 'shows pagination at top and bottom of the page' do
    render
    rendered.should have_selector('div.pagination', :count => 2)
  end

  it 'has a sortable header cell for the "id" column' do
    mock(view).sortable_header_cell :id, '#'
    render
  end

  it 'has a sortable header cell for the "summary" column' do
    mock(view).sortable_header_cell :summary, 'Summary'
    render
  end

  it 'has a sortable header cell for the "product" column' do
    mock(view).sortable_header_cell :product_id, 'Product'
    render
  end

  it 'has a sortable header cell for the "status" column' do
    mock(view).sortable_header_cell :status, 'Status'
    render
  end

  it 'has a sortable header cell for the "kind" column' do
    mock(view).sortable_header_cell :kind, 'Kind'
    render
  end

  it 'has a sortable header cell for the "when" column' do
    mock(view).sortable_header_cell :updated_at, 'When'
    render
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
