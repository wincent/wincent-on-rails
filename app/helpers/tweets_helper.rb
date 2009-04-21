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
        jQuery('\#spinner').show();
        jQuery.ajax({
          'url': '#{tweets_url}.js',
          'type': 'post',
          'dataType': 'html',
          'data': 'body=' + encodeURIComponent(jQuery('\#tweet_body').val()),
          'success': function(html) { jQuery('\#preview').html(html); },
          'error': function() { alert('an error occurred updating the preview'); },
          'complete': function() { jQuery('\#spinner').hide(); }
        });
        return false;
      JS
    end
    %Q{<a href="#" class="update_link" onclick="#{onclick}">update</a>}
  end

  def observe_body
    javascript_tag <<-JS
      observe_field({
        'field': jQuery('\#tweet_body'),
        'fieldName': 'body',
        'interval': 5,
        'url': '#{tweets_url}.js',
        'before': function() { jQuery('\#spinner').show(); },
        'success': function(html) { jQuery('\#preview').html(html); },
        'error': function(html) { alert('an error occurred updating the preview'); },
        'complete': function() { jQuery('\#spinner').hide(); },
      });
    JS
  end
end
