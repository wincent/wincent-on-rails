require 'rexml/document'
include REXML
file = File.new('other/mediawiki-dump.xml')
doc = Document.new(file)
doc.root.each_element('//page') do |page|
  title = page.elements['title'].text
  body = page.elements['revision'].elements['text'].text
  skip = [ /\ACategory:/, /\AHelp:/, /\AKnowledge Base:/, /\AMediaWiki:/, /\AUser talk:/, /\AUser:/ ]
  next if skip.any? { |re| title =~ re }
  begin
    if body =~ /\A\s*#REDIRECT\s+\[\[(.+)\]\]\s*\z/
      Article.create(:title => title, :redirect => "[[#{$~[1]}]]")
    else
      tags = []
      while true
        break unless body.sub!(/\[\[Category:([^\]]+)\]\]/) do |match|
          tags << $1
          ''
        end
      end
      tags = tags.collect { |tag| tag.downcase.gsub(/[^a-z]+/, '.') }
      pending_tags = tags.join(' ')
      Article.create(:title => title, :body => body, :pending_tags => pending_tags)
    end
  rescue Exception => e
    puts "Rescued exception for article title '#{title}': #{e.inspect}"
  end
end

