require 'spec_helper'

describe Page do
  describe 'attributes' do
    describe '#title' do
      it 'defaults to nil' do
        Page.new.title.should be_nil
      end
    end

    describe '#permalink' do
      it 'defaults to nil' do
        Page.new.permalink.should be_nil
      end
    end

    describe '#body' do
      it 'defaults to nil' do
        Page.new.body.should be_nil
      end
    end

    describe '#front' do
      it 'defaults to false' do
        Page.new.front.should == false
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        Page.new.created_at.should be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        Page.new.updated_at.should be_nil
      end
    end

    describe '#product_id' do
      it 'defaults to nil' do
        Page.new.product_id.should be_nil
      end
    end

    describe '#markup_type' do
      it 'defaults to HTML' do
        Page.new.markup_type.should == Page::MarkupType::HTML
      end
    end
  end

  describe '#to_param' do
    it 'returns permalink' do
      page = Page.make! :permalink => 'foo'
      page.to_param.should == 'foo'
    end

    context 'new record' do
      it 'returns nil' do
        Page.new.to_param.should == nil
      end
    end

    context 'dirty record' do
      it 'returns the old permalink' do
        page = Page.make! :permalink => 'foo'
        page.permalink = 'bar'
        page.to_param.should == 'foo'
      end
    end
  end
end

describe Page, 'validation' do
  it 'requires the title to be present' do
    Page.make(:title => '').should fail_validation_for(:title)
  end

  it 'requires the permalink to be present' do
    Page.make(:permalink => '').should fail_validation_for(:permalink)
  end

  it 'allows only letters, numbers and hyphens in the permalink' do
    Page.make(:permalink => '%__%').should fail_validation_for(:permalink)
  end

  it 'requires the body to be present' do
    Page.make(:body => nil).should fail_validation_for(:body)
  end

  it 'allows only known markup types (HTML and Wikitext)' do
    Page.make(:markup_type => 943).should fail_validation_for(:markup_type)
    Page.make(:markup_type => Page::MarkupType::HTML).should_not fail_validation_for(:markup_type)
    Page.make(:markup_type => Page::MarkupType::WIKITEXT).should_not fail_validation_for(:markup_type)
  end
end

describe Page, 'accessible attributes' do
  it 'should allow mass-assignment of the title attribute' do
    Page.make!.should allow_mass_assignment_of(:title => 'foo')
  end

  it 'should allow mass-assignment of the permalink attribute' do
    Page.make!.should allow_mass_assignment_of(:permalink => 'bar')
  end

  it 'should allow mass-assignment of the body attribute' do
    Page.make!.should allow_mass_assignment_of(:body => "<p>baz</p>\n")
  end

  it 'should allow mass-assignment of the markup_type attribute' do
    Page.make!.should allow_mass_assignment_of(:markup_type => Page::MarkupType::WIKITEXT)
  end

  it 'should allow mass-assignment of the front attribute' do
    Page.make!(:front => false).should allow_mass_assignment_of(:front => true)
  end
end

describe Page, 'body_html method' do
  it 'should return raw HTML for HTML markup' do
    page = Page.make! :body => '<em>foo</em>'
    page.body_html.should == '<em>foo</em>'
  end

  it 'should return transformed HTML for Wikitext markup' do
    page = Page.make! :body => "''foo''",
      :markup_type => Page::MarkupType::WIKITEXT
    page.body_html.should == "<p><em>foo</em></p>\n"
  end

  it 'should complain about unknown markup types' do
    page = Page.make :markup_type => 351
    lambda {
      page.body_html
    }.should raise_error(RuntimeError, /Unknown markup type/)
  end
end
