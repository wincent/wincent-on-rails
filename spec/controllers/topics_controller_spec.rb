require 'spec_helper'
require 'hpricot'

describe TopicsController do
  it_has_behavior 'ApplicationController protected methods'

  describe '#show (Atom)' do
    render_views # so that we can test layouts as well

    def do_get topic
      get :show, :forum_id => topic.forum.to_param, :id => topic.id, :format => 'atom', :protocol => 'https'
    end

    # make sure we don't get bitten by bugs like:
    # https://wincent.com/issues/1227
    it 'produces valid atom' do
      pending unless can_validate_feeds?
      do_get Topic.make!
      response.body.should be_valid_atom
    end

    # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
    it 'produces entry links to HTML-formatted records' do
      topic = Topic.make!
      10.times {
        # feed has one entry for topic, and one entry for each comment
        # so to fully catch this bug need some comments on the topic
        comment = topic.comments.build :body => Sham.random
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

    it 'redirects to aggregate forum feed (one forum) for non-existent topics' do
      pending 'broken because redirects to forum index HTML page'
    end

    it 'redirects to aggregate forum feed (all forums) for non-existent forums' do
      pending 'broken because redirects to all forums index HTML page'
    end
  end
end
