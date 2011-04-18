require 'spec_helper'

describe ArticlesHelper do
  describe '#redirected_from' do
    context 'with no article' do
      it 'returns nil' do
        helper.redirected_from.should be_nil
      end
    end

    context 'with an article' do
      let(:article) { Article.make! :title => 'foo' }

      before do
        @redirected_from = article
      end

      context 'as a non-admin user' do
        before do
          stub(helper).admin? { false }
        end

        it 'reports the article title' do
          helper.redirected_from.should == '<p>(Redirected from foo)</p>'
        end
      end

      context 'as an admin user' do
        before do
          stub(helper).admin? { true }
        end

        it 'includes an edit link' do
          expected = '<p>(Redirected from foo [<a href="/wiki/foo/edit">edit</a>])</p>'
          helper.redirected_from.should == expected
        end
      end
    end
  end
end
