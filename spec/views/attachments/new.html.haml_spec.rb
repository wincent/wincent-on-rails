require 'spec_helper'

describe 'attachments/new' do
  it 'says "Upload"' do
    render
    rendered.should have_content('Upload')
  end
end
