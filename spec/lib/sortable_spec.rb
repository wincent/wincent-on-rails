require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ActionView::Helpers::SortableHelper do
  describe '#sortable_header_cell' do
    include RSpec::Rails::HelperExampleGroup

    before do
      # need this or url_for will bail with:
      #   No route matches {:order => 'asc', :sort => 'foo'}
      # ideally would replace url_for entirely
      controller.params[:action] = 'index'
      controller.params[:controller] = 'issues'
      @cell = helper.sortable_header_cell :foo, 'bar'
    end

    it 'returns a "th" cell' do
      @cell.should have_selector('th')
    end

    it 'returns returns a link' do
      @cell.should have_selector('th a')
    end

    it 'uses the specified link text' do
      @cell.should have_selector('th a', :content => 'bar')
    end
  end
end