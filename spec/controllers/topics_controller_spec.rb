require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_controller_spec'

describe TopicsController do
  it_should_behave_like 'ApplicationController'
end

describe TopicsController, 'GET /forums/:forum_id/topics/:id.atom' do
  integrate_views # so that we can test layouts as well

  def do_get topic
    get :show, :forum_id => topic.forum.to_param, :id => topic.id, :format => 'atom', :protocol => 'https'
  end

  # make sure we don't get bitten by bugs like:
  # https://wincent.com/issues/1227
  it 'should produce valid atom' do
    pending unless can_validate_feeds?
    do_get create_topic
    response.body.should be_valid_atom
  end

  it 'should redirect to aggregate forum feed (one forum) for non-existent topics' do
    pending 'broken because redirects to forum index HTML page'
  end

  it 'should redirect to aggregate forum feed (all forums) for non-existent forums' do
    pending 'broken because redirects to all forums index HTML page'
  end
end
