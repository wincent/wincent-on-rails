# all create_foo and new_foo methods should produce valid instances, no exceptions raised
require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'FixtureReplacement example data' do
  describe 'create_article' do
    it 'should produce a valid instance' do
      create_article.should be_valid
    end
  end

  describe 'new_article' do
    it 'should produce a valid instance' do
      new_article.should be_valid
    end
  end

  describe 'create_attachment' do
    it 'should produce a valid instance' do
      pending 'remainder of attachment implementation'
      create_attachment.should be_valid
    end
  end

  describe 'new_attachment' do
    it 'should produce a valid instance' do
      pending 'remainder of attachment implementation'
      new_attachment.should be_valid
    end
  end

  describe 'create_comment' do
    it 'should produce a valid instance' do
      create_comment.should be_valid
    end
  end

  describe 'new_comment' do
    it 'should produce a valid instance' do
      new_comment.should be_valid
    end
  end

  describe 'create_confirmation' do
    it 'should produce a valid instance' do
      create_confirmation.should be_valid
    end
  end

  describe 'new_confirmation' do
    it 'should produce a valid instance' do
      new_confirmation.should be_valid
    end
  end

  describe 'create_email' do
    it 'should produce a valid instance' do
      create_email.should be_valid
    end
  end

  describe 'new_email' do
    it 'should produce a valid instance' do
      new_email.should be_valid
    end
  end

  describe 'create_forum' do
    it 'should produce a valid instance' do
      create_forum.should be_valid
    end
  end

  describe 'new_forum' do
    it 'should produce a valid instance' do
      new_forum.should be_valid
    end
  end

  describe 'create_issue' do
    it 'should produce a valid instance' do
      create_issue.should be_valid
    end
  end

  describe 'new_issue' do
    it 'should produce a valid instance' do
      new_issue.should be_valid
    end
  end

  describe 'create_link' do
    it 'should produce a valid instance' do
      create_link.should be_valid
    end
  end

  describe 'new_link' do
    it 'should produce a valid instance' do
      new_link.should be_valid
    end
  end

  describe 'create_message' do
    it 'should produce a valid instance' do
      create_message.should be_valid
    end
  end

  describe 'new_message' do
    it 'should produce a valid instance' do
      new_message.should be_valid
    end
  end

  describe 'create_needle' do
    it 'should produce a valid instance' do
      create_needle.should be_valid
    end
  end

  describe 'new_needle' do
    it 'should produce a valid instance' do
      new_needle.should be_valid
    end
  end

  describe 'create_page' do
    it 'should produce a valid instance' do
      create_page.should be_valid
    end
  end

  describe 'new_page' do
    it 'should produce a valid instance' do
      new_page.should be_valid
    end
  end

  describe 'create_post' do
    it 'should produce a valid instance' do
      create_post.should be_valid
    end
  end

  describe 'new_post' do
    it 'should produce a valid instance' do
      new_post.should be_valid
    end
  end

  describe 'create_product' do
    it 'should produce a valid instance' do
      create_product.should be_valid
    end
  end

  describe 'new_product' do
    it 'should produce a valid instance' do
      new_product.should be_valid
    end
  end

  describe 'create_reset' do
    it 'should produce a valid instance' do
      create_reset.should be_valid
    end
  end

  describe 'new_reset' do
    it 'should produce a valid instance' do
      new_reset.should be_valid
    end
  end

  describe 'create_tag' do
    it 'should produce a valid instance' do
      create_tag.should be_valid
    end
  end

  describe 'new_tag' do
    it 'should produce a valid instance' do
      new_tag.should be_valid
    end
  end

  describe 'create_tagging' do
    it 'should produce a valid instance' do
      create_tagging.should be_valid
    end
  end

  describe 'new_tagging' do
    it 'should produce a valid instance' do
      new_tagging.should be_valid
    end
  end

  describe 'create_topic' do
    it 'should produce a valid instance' do
      create_topic.should be_valid
    end
  end

  describe 'new_topic' do
    it 'should produce a valid instance' do
      new_topic.should be_valid
    end
  end

  describe 'create_tweet' do
    it 'should produce a valid instance' do
      create_tweet.should be_valid
    end
  end

  describe 'new_tweet' do
    it 'should produce a valid instance' do
      new_tweet.should be_valid
    end
  end

  describe 'create_user' do
    it 'should produce a valid instance' do
      create_user.should be_valid
    end
  end

  describe 'new_user' do
    it 'should produce a valid instance' do
      new_user.should be_valid
    end
  end

  describe 'create_word' do
    it 'should produce a valid instance' do
      create_word.should be_valid
    end
  end

  describe 'new_word' do
    it 'should produce a valid instance' do
      new_word.should be_valid
    end
  end
end
