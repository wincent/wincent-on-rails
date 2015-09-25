require 'spec_helper'

describe 'issues/_issues' do
  before do
    # needed for sortable_header_cell because it calls url_for
    controller.params[:controller] = 'issues'
    controller.params[:action] = 'index'
    @issues = Array.new(4) { Issue.make! }
  end

  describe 'regressions' do
    it 'has a sortable header cell for the "id" column' do
      render
      within('th a', text: '#') do |link|
        expect(link[:href]).to match('sort=id')
      end
    end

    it 'has a sortable header cell for the "summary" column' do
      render
      within('th a', text: 'Summary') do |link|
        expect(link[:href]).to match('sort=summary')
      end
    end

    it 'has a sortable header cell for the "product" column' do
      render
      within('th a', text: 'Product') do |link|
        expect(link[:href]).to match('sort=product_id')
      end
    end

    it 'has a sortable header cell for the "status" column' do
      render
      within('th a', text: 'Status') do |link|
        expect(link[:href]).to match('sort=status')
      end
    end

    it 'has a sortable header cell for the "kind" column' do
      render
      within('th a', text: 'Kind') do |link|
        expect(link[:href]).to match('sort=kind')
      end
    end

    it 'has a sortable header cell for the "when" column' do
      render
      within('th a', text: 'When') do |link|
        expect(link[:href]).to match('sort=updated_at')
      end
    end
  end
end
