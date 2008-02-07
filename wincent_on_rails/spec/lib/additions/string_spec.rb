require File.dirname(__FILE__) + '/../../spec_helper'
require 'additions/string'

describe String, 'to_wikitext method' do
  it 'should convert wikitext markup into HTML' do
    'hello world'.to_wikitext.should == "<p>hello world</p>\n"
  end
end

describe String, 'w alias' do
  it 'should convert wikitext markup into HTML' do
    'hello world'.w.should == "<p>hello world</p>\n"
  end
end
