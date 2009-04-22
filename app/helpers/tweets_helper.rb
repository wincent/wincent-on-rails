module TweetsHelper
  def atom_title tweet
    stripped    = strip_tags tweet.body.w
    compressed  = stripped.gsub /\s+/, ' '
    compressed.strip!
    truncate compressed, :length => 80
  end

  def character_count tweet
    pluralizing_count tweet.rendered_length, 'character'
  end

  def link_to_update_preview
    onclick = inline_js do
      <<-JS
        $('\#spinner').show();
        $.ajax({
          'url': '#{tweets_url}.js',
          'type': 'post',
          'dataType': 'html',
          'data': 'body=' + encodeURIComponent($('\#tweet_body').val()),
          'success': function(html) {
            $('\#preview').html(html);
            clearAJAXFlash();
          },
          'error': function(req) {
            insertAJAXFlash('error', req.responseText);
          },
          'complete': function() { $('\#spinner').hide(); }
        });
        return false;
      JS
    end
    %Q{<a href="#" class="update_link" onclick="#{onclick}">update</a>}
  end
end
