require 'spec_helper'

describe ActiveRecord::Acts::Taggable do
  # Create a model purely for testing purposes so as to avoid depending on a
  # real model from the application.
  class ActsAsTaggableTestModel < ActiveRecord::Base
    acts_as_taggable
  end

  before :all do
    # There are no plans to extract this into a separate plug-in, so piggy-back
    # on the application's own test database. (An extracted version would need
    # to set up an in-memory SQLite database; see the acts_as_list plug-in for
    # an example.)
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :acts_as_taggable_test_models do |t|
        t.string :title
      end
    end
  end

  after :all do
    ActsAsTaggableTestModel.destroy_all
    ActiveRecord::Base.connection.drop_table 'acts_as_taggable_test_models'
  end

  it_has_behavior 'taggable' do
    let(:model) { ActsAsTaggableTestModel.create }
    let(:new_model) { ActsAsTaggableTestModel.new }
  end

  let(:model) { ActsAsTaggableTestModel.create }

  describe 'adding tag(s)' do
    context 'no parameters' do
      it 'does nothing' do
        expect do
          model.tag
        end.to_not change { model.tags.size }
      end
    end

    context 'a string with a single tag' do
      it 'adds a single tag' do
        expect do
          model.tag 'foo'
        end.to change { model.tags.size }.by(1)
      end

      it 'increments the counter cache' do
        Tag.make! :name => 'foo'
        expect do
          model.tag 'foo'
        end.to change { Tag.find_by_name('foo').taggings_count }.by(1)
      end
    end

    context 'multiple, space-delimited tags' do
      it 'adds multiple tags' do
        expect do
          model.tag 'foo bar baz'
        end.to change { model.tags.size }.by(3)
      end
    end

    context 'excess whitespace' do
      it 'ignores excess trailing or leading whitespace' do
        expect do
          model.tag '    foo   ,  bar  ,   baz  '
        end.to change { model.tags.size }.by(3)
      end
    end

    context 'repeated items' do
      it 'adds repeated items only once' do
        expect do
          model.tag 'foo foo foo'
        end.to change { model.tags.size }.by(1)
      end
    end

    context 'tags which have already been applied' do
      it 'has no effect' do
        expect do
          model.tag 'foo'
        end.to change { model.tags.size }.by(1)
        expect do
          model.tag 'foo'
        end.to_not change { model.tags.size }
      end
    end

    context 'array parameter' do
      it 'accepts an array as a parameter' do
        expect do
          model.tag ['foo', 'bar']
        end.to change { model.tags.size }.by(2)
      end
    end

    context 'nested array' do
      it 'handles nested arrays' do
        expect do
          model.tag ['foo', ['bar', 'baz abc']]
        end.to change { model.tags.size }.by(4)
      end
    end
  end

  describe 'removing tag(s)' do
    context 'no parameters' do
      it 'does nothing' do
        model.tag 'foo bar baz'
        expect do
          model.untag
        end.to_not change { model.tags.size }
      end
    end

    context 'single tag' do
      it 'removes a single tag' do
        model.tag 'foo bar baz'
        expect do
          model.untag 'foo'
        end.to change { model.tags.size }.by(-1)
      end

      it 'decrements the counter cache' do
        model.tag 'foo'
        expect do
          model.untag 'foo'
        end.to change { Tag.find_by_name('foo').taggings_count }.by(-1)
      end
    end

    context 'multiple, space-delimited tags' do
      it 'removes' do
        model.tag 'foo bar baz'
        expect do
          model.untag 'foo bar'
        end.to change { model.tags.size }.by(-2)
      end
    end

    context 'excess whitespace' do
      it 'ignores excess trailing or leading whitespace' do
        model.tag 'foo bar baz'
        expect do
          model.untag '    foo    ,    bar    '
        end.to change { model.tags.size }.by(-2)
      end
    end

    context 'repeated items' do
      it 'handles repeated items' do
        model.tag 'foo bar baz'
        expect do
          model.untag 'foo foo'
        end.to change { model.tags.size }.by(-1)
      end
    end

    context 'tags which have already been removed' do
      it 'has no effect for tags which have already been removed' do
        model.tag 'foo bar baz'
        expect do
          model.untag 'foo'
        end.to change { model.tags.size }.by(-1)
        expect do
          model.untag 'foo'
        end.to_not change { model.tags.size }
      end
    end

    context 'unknown tags' do
      it 'has no effect' do
        model.tag 'foo bar baz'
        expect do
          model.untag 'abc'
        end.to_not change { model.tags.size }
      end
    end

    context 'array parameter' do
      it 'accepts' do
        model.tag 'foo bar baz'
        expect do
          model.untag ['foo', 'bar']
        end.to change { model.tags.size }.by(-2)
      end
    end

    context 'nested arrays' do
      it 'handles nested arrays' do
        model.tag 'foo bar baz'
        expect do
          model.untag ['foo', ['bar']]
        end.to change { model.tags.size }.by(-2)
      end
    end
  end

  describe 'getting a list of tag name(s)' do
    it 'returns an array of tag names' do
      model.tag 'foo bar baz'
      expect(model.tag_names).to match_array(['bar', 'baz', 'foo'])
    end

    context 'no tags' do
      it 'returns an empty array' do
        expect(model.tag_names).to eq([])
      end
    end
  end
end
