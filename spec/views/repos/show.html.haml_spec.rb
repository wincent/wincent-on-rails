require 'spec_helper'

describe 'repos/show' do
  before do
    @repo = Repo.make!
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

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
