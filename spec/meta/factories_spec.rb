require 'spec_helper'

describe 'Factories' do
  %w[
    Article
    Comment
    Email
    Issue
    Link
    Page
    Post
    Product
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
