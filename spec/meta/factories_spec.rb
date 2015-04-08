require 'spec_helper'

describe 'Factories' do
  %w[
    Article
    Attachment
    Comment
    Confirmation
    Email
    Forum
    Issue
    Link
    Message
    Monitorship
    Needle
    Page
    Post
    Product
    Repo
    Reset
    Snippet
    Tag
    Tagging
    Topic
    User
    Word
  ].map(&:constantize).each do |model_class|

    describe "#{model_class}.make!" do
      it 'produces a valid instance' do
        expect(model_class.make!).to be_valid
      end
    end

    describe "#{model_class}.make" do
      it 'produces a valid instance' do
        expect(model_class.make).to be_valid
      end
    end
  end
end
