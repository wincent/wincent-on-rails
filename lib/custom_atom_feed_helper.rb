# Simplified version of the official AtomFeedHelper module from the official Rails repo:
#
# - get rid of a lot of overridable, dynamic stuff and replace it with hard-coded values
# - require "updated" to be specifically specified rather than defaulting to "now"
# - provide mechanism for overriding URLs rather than just calling polymorphic_url
#   (useful for example when we want to craft links which include anchors, like "/issues/1300#comment_4235")
#
# For information on the Atom format see:
# - http://www.atomenabled.org/developers/syndication/                      (nice summary)
# - http://www.atomenabled.org/developers/syndication/atom-format-spec.php  (exhaustive description)
module CustomAtomFeedHelper
  def custom_atom_feed &block
    xml = eval 'xml', block.binding
    xml.instruct!

    # Required feed elements:     title, id, updated
    # Recommended feed elements:  author, link
    # Optional feed elements:     category, contributor, generator, icon, logo, rights, subtitle
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

    # Required entry elements:    id, title, updated
    # Recommended entry elements: author, content, link, summary
    # Optional entry elements:    category, contributor, published, source, rights
    def entry model, options = {}, &block
      @xml.entry do
        # on generating unique tag URIs:  http://diveintomark.org/archives/2004/05/28/howto-atom-id
        # see also:                       http://www.taguri.org/
        # =>                              http://www.faqs.org/rfcs/rfc4151.html
        @xml.id "tag:#{@view.request.host},2008:#{model.class.to_s.tableize}/#{model.id}"
        @xml.published model.created_at.xmlschema
        @xml.updated model.updated_at.xmlschema

        # Rails 2.3.0 RC1 BUG: polymorphic_url now returns atom links instead of HTML ones here
        # See: http://rails.lighthouseapp.com/projects/8994/tickets/2043
        @xml.link :rel => 'alternate', :type => 'text/html', :href => options[:url] || @view.polymorphic_url(model, :format => nil)
        yield @xml
      end
    end

  private

    def method_missing method, *args, &block
      @xml.__send__ method, *args, &block
    end
  end # class AtomFeedBuilder
end # module AtomFeedHelper
