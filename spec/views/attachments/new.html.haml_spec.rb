require 'spec_helper'

describe 'attachments/new' do
  it 'says "Upload"' do
    render
    expect(rendered).to have_content('Upload')
  end
end
