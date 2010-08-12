require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'repos/show' do
  it 'has breadcrumbs'
  it 'shows the repo name'
  it 'shows the description'
  it 'shows the repo clone URL'
  it 'shows the associated product'
  context 'normal user' do
    it 'does not show the repo read/write clone URL'
    it 'does not show the repo path'
  end

  context 'admin user' do
    it 'shows the repo read/write clone URL'
    it 'shows the repo path'
    it 'shows the repo public attribute'
  end
end
