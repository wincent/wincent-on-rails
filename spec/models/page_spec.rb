require 'spec_helper'

describe Page do
  describe 'attributes' do
    describe '#title' do
      it 'defaults to nil' do
        expect(Page.new.title).to be_nil
      end
    end

    describe '#permalink' do
      it 'defaults to nil' do
        expect(Page.new.permalink).to be_nil
      end
    end

    describe '#body' do
      it 'defaults to nil' do
        expect(Page.new.body).to be_nil
      end
    end

    describe '#front' do
      it 'defaults to false' do
        expect(Page.new.front).to eq(false)
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        expect(Page.new.created_at).to be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        expect(Page.new.updated_at).to be_nil
      end
    end

    describe '#product_id' do
      it 'defaults to nil' do
        expect(Page.new.product_id).to be_nil
      end
    end

    describe '#markup_type' do
      it 'defaults to HTML' do
        expect(Page.new.markup_type).to eq(Page::MarkupType::HTML)
      end
    end
  end

  describe '#to_param' do
    it 'returns permalink' do
      page = Page.make! :permalink => 'foo'
      expect(page.to_param).to eq('foo')
    end

    context 'new record' do
      it 'returns nil' do
        expect(Page.new.to_param).to eq(nil)
      end
    end

    context 'dirty record' do
      it 'returns the old permalink' do
        page = Page.make! :permalink => 'foo'
        page.permalink = 'bar'
        expect(page.to_param).to eq('foo')
      end
    end
  end
end

describe Page, 'validation' do
  it 'requires the title to be present' do
    expect(Page.make(:title => '')).to fail_validation_for(:title)
  end

  it 'requires the permalink to be present' do
    expect(Page.make(:permalink => '')).to fail_validation_for(:permalink)
  end

  it 'allows only letters, numbers and hyphens in the permalink' do
    expect(Page.make(:permalink => '%__%')).to fail_validation_for(:permalink)
  end

  it 'requires the body to be present' do
    expect(Page.make(:body => nil)).to fail_validation_for(:body)
  end

  it 'allows only known markup types (HTML and Wikitext)' do
    expect(Page.make(:markup_type => 943)).to fail_validation_for(:markup_type)
    expect(Page.make(:markup_type => Page::MarkupType::HTML)).not_to fail_validation_for(:markup_type)
    expect(Page.make(:markup_type => Page::MarkupType::WIKITEXT)).not_to fail_validation_for(:markup_type)
  end
end

describe Page, 'accessible attributes' do
  it 'should allow mass-assignment of the title attribute' do
    expect(Page.make!).to allow_mass_assignment_of(:title => 'foo')
  end

  it 'should allow mass-assignment of the permalink attribute' do
    expect(Page.make!).to allow_mass_assignment_of(:permalink => 'bar')
  end

  it 'should allow mass-assignment of the body attribute' do
    expect(Page.make!).to allow_mass_assignment_of(:body => "<p>baz</p>\n")
  end

  it 'should allow mass-assignment of the markup_type attribute' do
    expect(Page.make!).to allow_mass_assignment_of(:markup_type => Page::MarkupType::WIKITEXT)
  end

  it 'should allow mass-assignment of the front attribute' do
    expect(Page.make!(:front => false)).to allow_mass_assignment_of(:front => true)
  end
end

describe Page, 'body_html method' do
  it 'should return raw HTML for HTML markup' do
    page = Page.make! :body => '<em>foo</em>'
    expect(page.body_html).to eq('<em>foo</em>')
  end

  it 'should return transformed HTML for Wikitext markup' do
    page = Page.make! :body => "''foo''",
      :markup_type => Page::MarkupType::WIKITEXT
    expect(page.body_html).to eq("<p><em>foo</em></p>\n")
  end

  it 'should complain about unknown markup types' do
    page = Page.make :markup_type => 351
    expect {
      page.body_html
    }.to raise_error(RuntimeError, /Unknown markup type/)
  end
end
