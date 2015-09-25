require 'spec_helper'

describe 'Factories' do
  %w[
    Article
    Comment
    Confirmation
    Email
    Issue
    Link
    Message
    Monitorship
    Page
    Post
    Product
    Reset
    Snippet
    Tag
    Tagging
    User
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
