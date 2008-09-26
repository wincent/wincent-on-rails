require File.dirname(__FILE__) + '/../../spec_helper'

describe "/articles/index.atom.builder" do
  include ArticlesHelper

  def do_render
    render '/articles/index.atom.builder'
  end

  it 'should handle no articles' do
    assigns[:articles] = []
    lambda { do_render }.should_not raise_error
  end
end
