require 'spec_helper'

describe IssuesHelper do
  describe '#search_info' do
    context 'no "issue" param' do
      it 'returns nil' do
        stub(helper).params { {} }
        expect(helper.search_info).to be_nil
      end
    end

    context 'single criterion' do
      it 'returns a description of the criterion' do
        stub(helper).params {{ :issue => { :kind => '2' }}}
        expect(helper.search_info).to eq('Currently showing only issues with kind: support ticket')
      end
    end

    context 'multiple criteria' do
      it 'returns a list of criteria' do
        product = Product.make! :name => 'foo'
        stub(helper).params {{ :issue => {
          :product_id => product.id.to_s,
          :kind => '1',
          :status => '2',
          :summary => 'bar'
        }}}
        expect(helper.search_info).to eq("Currently showing only issues with product: foo, kind: feature request, status: closed, matching text: bar")
      end
    end
  end
end
