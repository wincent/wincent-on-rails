require 'spec_helper'

describe 'links/index' do
  before do
    stub(view).sortable_header_cell.with_any_args
    link_98 = Link.make! permalink: 'perma98'
    link_99 = Link.make! permalink: 'perma99'
    @links = [link_98, link_99]
  end

  it 'renders list of links' do
    render
    expect(rendered).to have_css('tr>td', text: 'perma98')
    expect(rendered).to have_css('tr>td', text: 'perma99')
  end

  it 'uses sortable header cells' do
    mock(view).sortable_header_cell :id, 'Id'
    mock(view).sortable_header_cell :uri, 'URI'
    mock(view).sortable_header_cell :permalink, 'Permalink'
    mock(view).sortable_header_cell :click_count, 'Click count'
    render
  end
end

