require 'spec_helper'

describe 'links/new' do
  before do
    @link = Link.make
  end

  it 'renders new form' do
    render
    within("form[method=post][action='#{links_path}']") do |form|
      expect(form).to have_css('input#link_uri[name="link[uri]"]')
      expect(form).to have_css('input#link_permalink[name="link[permalink]"]')
    end
  end
end
