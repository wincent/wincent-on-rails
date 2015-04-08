require 'spec_helper'

describe Paginator do
  before do
    @params = {
      'protocol' => 'https',
      'action' => 'index',
      'controller' => 'articles',
      'page' => '2',
      'sort' => 'title',
      'order' => 'asc'
    }
    @count = 102
    @url = 'https://example.com/wiki'
    @paginator = Paginator.new @params, @count, @url
  end

  it 'should filter "action" from the parameter hash' do
    expect(@paginator.pagination_links).not_to match(/action/)
  end

  it 'should filter "controller" from the parameter hash' do
    expect(@paginator.pagination_links).not_to match(/controller/)
  end

  it 'should filter "protocol" from the parameter hash' do
    expect(@paginator.pagination_links).not_to match(/protocol/)
  end

  it 'should preserve protocol from URL' do
    expect(@paginator.pagination_links).to match(/https/)
  end

  it 'should preserve other parameters' do
    expect(@paginator.pagination_links).to match(/sort/)
    expect(@paginator.pagination_links).to match(/order/)
  end

  it 'should preserve nested parameter hashes'

  it 'should raise ActiveRecord::RecordNotFound if page number if out of range' do
    params = @params.clone
    params[:page] = @count # way out of range
    expect { Paginator.new(params, @count, @url) }.to raise_error(ActiveRecord::RecordNotFound)
    params[:page] = (@count / 10) + 2 # just out of range
    expect { Paginator.new(params, @count, @url) }.to raise_error(ActiveRecord::RecordNotFound)
    params[:page] = (@count / 10) + 1 # just in of range
    expect { Paginator.new(params, @count, @url) }.to_not raise_error
  end
end
