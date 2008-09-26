require File.dirname(__FILE__) + '/../../spec_helper'

describe "/posts/index.atom.builder" do
  include PostsHelper

  def do_render
    render '/posts/index.atom.builder'
  end

  it 'should handle no posts' do
    assigns[:posts] = []
    lambda { do_render }.should_not raise_error
  end
end
