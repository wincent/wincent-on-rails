require 'spec_helper'

describe ApplicationHelper, 'timeinfo method' do
  before do
    @model = stub!.created_at { 2.days.ago }.subject
    stub(@model).updated_at { 3.days.ago }
  end

  it 'should get the creation date' do
    mock(@model).created_at { Time.now }
    timeinfo @model
  end

  it 'should get update date' do
    mock(@model).updated_at { Time.now }
    timeinfo @model
  end

  it 'returns just the creation date if update and creation date are the same (exact match)' do
    date = 2.days.ago
    mock(@model).created_at { date }
    mock(@model).updated_at { date }
    expect(timeinfo(@model)).to match(/#{Regexp.escape date.xmlschema}/)
  end

  it 'returns just the creation date if update and creation date are the same (fuzzy match)' do
    earlier_date  = (2.days + 2.hours).ago
    later_date    = (2.days + 1.hour).ago
    mock(@model).created_at { earlier_date }
    mock(@model).updated_at { later_date }
    expect(earlier_date.distance_in_words).to eq(later_date.distance_in_words) # check our assumption about fuzzy equality
    expect(timeinfo(@model)).to match(/#{Regexp.escape earlier_date.xmlschema}/)
  end

  it 'returns both creation and edit date if different' do
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    mock(@model).created_at { earlier_date }
    mock(@model).updated_at { later_date }
    expect(earlier_date.distance_in_words).not_to eq(later_date.distance_in_words) # check our assumption about inequality
    info = timeinfo(@model)
    expect(info).to match(/Created.+#{Regexp.escape earlier_date.xmlschema}/)
    expect(info).to match(/updated.+#{Regexp.escape later_date.xmlschema}/)
  end

  it 'allows you to override the "updated" string' do
    # for some model types, it might sound better to say "edited" rather than updated
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    mock(@model).created_at { earlier_date }
    mock(@model).updated_at { later_date }
    info = timeinfo(@model, updated_string: 'edited')
    expect(info).to match(/Created.+#{Regexp.escape earlier_date.xmlschema}/)
    expect(info).to match(/edited.+#{Regexp.escape later_date.xmlschema}/)
  end

  it 'does not show the "updated" date at all if "updated_string" is set to false' do
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    mock(@model).created_at { earlier_date }
    mock(@model).updated_at { later_date }
    info = timeinfo @model, updated_string: false
    expect(info).to match(/#{Regexp.escape earlier_date.xmlschema}/)
    expect(info).not_to match(/#{Regexp.escape later_date.xmlschema}/)
  end
end

describe ApplicationHelper, 'underscores_to_spaces method' do
  it 'should return an array of name/id pairs' do
    hash = { 'foo' => 1, 'bar' => 2 }
    expect(underscores_to_spaces(hash)).to match_array([['foo', 1], ['bar', 2]])
  end

  it 'should convert underscores to spaces' do
    hash = { 'foo_bar' => 1, 'baz_bar' => 2 }
    expect(underscores_to_spaces(hash)).to match_array([['foo bar', 1], ['baz bar', 2]])
  end

  it 'should convert symbol-based keys to strings' do
    hash = { foo: 1, bar: 2 }
    expect(underscores_to_spaces(hash)).to match_array([['foo', 1], ['bar', 2]])
  end
end

describe ApplicationHelper do
  # required in Rails 3.1, not sure why it wasn't before; without it,
  # these specs fail when the #breadcrumbs method calls h() from
  # ::ERB::Util, while other helper methods that #breadcrumbs uses
  # (for example, #content_tag and #link_to) work regardless
  include ::ERB::Util

  describe '#breadcrumbs' do
    it 'returns an HTML-safe string' do
      expect(breadcrumbs('foo')).to be_html_safe
    end

    it 'escapes non-HTML-safe strings' do
      expect(breadcrumbs('"foo"')).to match(/&quot;foo&quot;/)
    end

    # was a regression, introduced in the move from Rails 3.0.1 to 3.0.3
    it 'does not escape links' do
      # link_to returns HTML-safe strings, so mimic it
      expect(breadcrumbs('<a href="/foo">'.html_safe, 'bar')).to match(%r{<a href="/foo">})
    end

    # was a regression, introduced in the move from Rails 3.0.1 to 3.0.3
    it 'does not inappropriately escape "raquo" entities' do
      expect(breadcrumbs('foo')).to match(/&raquo;/)
    end
  end

  describe '#link_to_model' do
    it 'works with articles' do
      article = Article.make!
      link = link_to(article.title, article_path(article))
      expect(link_to_model(article)).to eq(link)
    end

    it 'works with posts' do
      post = Post.make!
      expect(link_to_model(post)).to eq(link_to(post.title, post_path(post)))
    end

    context 'with a snippet' do
      let(:snippet) { Snippet.make! }

      # TODO: in next Capybara release use selector-based tests here
      it 'links to the snippet' do
        expect(link_to_model(snippet)).to include(snippet_path(snippet))
      end

      context 'description is available' do
        let(:snippet) { Snippet.make! description: 'foobar' }

        it 'uses the snippet title' do
          expect(link_to_model(snippet)).to match(/foobar/)
        end
      end
    end

    # was a bug
    it 'escapes HTML special characters (such as in issue summaries)' do
      issue = Issue.make! summary: '<em>foo</em>'
      expect(link_to_model(issue)).not_to match(/<em>/)
    end
  end

  describe '#wikitext_truncate_and_strip' do
    it 'strips out wikitext markup' do
      expect(wikitext_truncate_and_strip("''fun''")).to eq('fun') # quotes are gone
    end

    it 'truncates long output' do
      expect(wikitext_truncate_and_strip('long long long', length: 10)).
        to eq('long lo...')
    end

    it 'marks output as HTML-safe' do
      output = wikitext_truncate_and_strip 'foo & bar'
      expect(output).to be_html_safe        # it is marked as safe
      expect(output).to eq('foo &amp; bar')  # and it really is safe
    end

    it 'applies any custom "omission" option' do
      output = wikitext_truncate_and_strip 'foo, bar, baz, bing, bong',
        length: 18, omission: '[snip]'
      expect(output).to eq('foo, bar, ba[snip]')
    end

    context 'truncation which cuts an entity in half' do
      it 'removes the mangled entity' do
        output = wikitext_truncate_and_strip 'foo, bar & baz', length: 14
        expect(output).to eq('foo, bar ...') # safe output
        expect(output).to be_html_safe      # and marked as such
      end
    end

    context 'truncation which leaves entities intact' do
      it 'marks the output as HTML safe' do
        output = wikitext_truncate_and_strip 'foo & bar etc', length: 15
        expect(output).to eq('foo &amp; ba...')  # safe output
        expect(output).to be_html_safe          # and marked as such
      end
    end
  end
end
