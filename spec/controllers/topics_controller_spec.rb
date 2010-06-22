require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_controller_spec'
require 'hpricot'

describe TopicsController do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
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

  # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
  it 'should produce entry links to HTML-formatted records' do
    topic = create_topic
    10.times {
      # feed has one entry for topic, and one entry for each comment
      # so to fully catch this bug need some comments on the topic
      comment = topic.comments.build :body => FR::random_string
      comment.awaiting_moderation = false
      comment.save
    }
    do_get topic
    doc = Hpricot.XML(response.body)
    (doc/:entry).collect do |entry|
      (entry/:link).first[:href].each do |href|
        # make sure links are /topics/1234#comment_3000, not /topics/1234.atom#comment_3000
        href.should_not =~ %r{\.atom}
      end
    end
  end

  it 'should redirect to aggregate forum feed (one forum) for non-existent topics' do
    pending 'broken because redirects to forum index HTML page'
  end

  it 'should redirect to aggregate forum feed (all forums) for non-existent forums' do
    pending 'broken because redirects to all forums index HTML page'
  end
end
