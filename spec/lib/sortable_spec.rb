require 'spec_helper'

describe ActionView::Helpers::SortableHelper do
  describe '#sortable_header_cell' do
    include RSpec::Rails::HelperExampleGroup

    before do
      # need this or url_for will bail with:
      #   No route matches {:order => 'asc', :sort => 'foo'}
      # ideally would replace url_for entirely
      controller.params[:action] = 'index'
      controller.params[:controller] = 'issues'

      # TODO: after move to Capybara 1.0.0, might be able to do this
      #       without explicitly wrapping using Capybara.string
      #       (but Akephalos is currently blocker for moving to
      #       Capybara 1.0.0; consider switching to zombie.js)
      @cell = Capybara.string(helper.sortable_header_cell :foo, 'bar')
    end

    it 'returns a "th" cell' do
      @cell.should have_css('th')
    end

    it 'returns returns a link' do
      @cell.should have_css('th a')
    end

    it 'uses the specified link text' do
      @cell.should have_css('th a', :content => 'bar')
    end
  end
end
