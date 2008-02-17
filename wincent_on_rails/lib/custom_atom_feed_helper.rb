# Simplified version of the official AtomFeedHelper module from the official Rails repo:
# - get rid of a lot of overridable, dynamic stuff and replace it with hard-coded values
# - require "updated" to be specifically specified rather than defaulting to "now"
# - fix one bug (use of "id" rather than "to_param")
# - work around failure of polymorphic_url method when resource has :controller override in routes.rb
module CustomAtomFeedHelper
  def custom_atom_feed &block
    xml = eval 'xml', block.binding
    xml.instruct!
    xml.feed 'xml:lang' => 'en-US', 'xmlns' => 'http://www.w3.org/2005/Atom' do
      xml.id "tag:#{request.host},2008:#{request.request_uri.split('.')[0]}"
      xml.link :rel => 'alternate', :type => 'text/html', :href => request.url.gsub(/\.atom$/, '')
      xml.link :rel => 'self', :type => 'application/atom+xml', :href => request.url
      yield CustomAtomFeedBuilder.new(xml, self)
    end
  end

  class CustomAtomFeedBuilder
    def initialize xml, view
      @xml      = xml
      @view     = view
    end

    def updated date_or_time
      @xml.updated date_or_time.xmlschema
    end

    def entry model, options = {}, &block
      @xml.entry do
        @xml.id "tag:#{@view.request.host},2008:#{model.class}/#{model.to_param}"
        @xml.published model.created_at.xmlschema
        @xml.updated model.updated_at.xmlschema

        # polymorphic_url fails: tries to call post_url on view (needs to be blog_url)
        @xml.link :rel => 'alternate', :type => 'text/html', :href => options[:url] || @view.polymorphic_url(model)
        yield @xml
      end
    end

  private

    def method_missing method, *args, &block
      @xml.__send__ method, *args, &block
    end
  end # class AtomFeedBuilder
end # module AtomFeedHelper
