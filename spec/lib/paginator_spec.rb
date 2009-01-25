require File.dirname(__FILE__) + '/../spec_helper'

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
    @paginator = Paginator.new @params, 102, @url
  end

  it 'should filter "action" from the parameter hash' do
    @paginator.pagination_links.should_not =~ /action/
  end

  it 'should filter "controller" from the parameter hash' do
    @paginator.pagination_links.should_not =~ /controller/
  end

  it 'should filter "protocol" from the parameter hash' do
    @paginator.pagination_links.should_not =~ /protocol/
  end

  it 'should preserve protocol from URL' do
    @paginator.pagination_links.should =~ /https/
  end

  it 'should preserve other parameters' do
    @paginator.pagination_links.should =~ /sort/
    @paginator.pagination_links.should =~ /order/
  end

  it 'should preserve nested parameter hashes'
end
