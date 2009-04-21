module ArticlesHelper
  def title_and_body_html
    text = []
    text << (@article.title.blank? ? '' : "= #{@article.title} =")
    text << @article.body
    text.join("\n\n").w :base_heading_level => 2
  end

  def link_to_update_preview
    onclick = inline_js do
      <<-JS
        jQuery('\#spinner').show();
        jQuery.ajax({
          'url': '#{articles_url}.js',
          'type': 'post',
          'dataType': 'html',
          'data': 'title=' + encodeURIComponent(jQuery('\#article_title').val()) +
            '&body=' + encodeURIComponent(jQuery('\#article_body').val()),
          'success': function(html) { jQuery('\#preview').html(html); },
          'error': function() { alert('an error occurred updating the preview'); },
          'complete': function() { jQuery('\#spinner').hide(); }
        });
        return false;
      JS
    end
    %Q{<a href="#" class="update_link" onclick="#{onclick}">update</a>}
  end

  def observe_title
    javascript_tag <<-JS
      observe_field({
        'kind': 'article',
        'field': jQuery('\#article_title'),
        'fieldName': 'title',
        'include': ['body'],
        'interval': 30,
        'url': '#{articles_url}.js',
        'before': function() { jQuery('\#spinner').show(); },
        'success': function(html) { jQuery('\#preview').html(html); },
        'error': function(html) { alert('an error occurred updating the preview'); },
        'complete': function() { jQuery('\#spinner').hide(); },
      });
    JS
  end

  def observe_body
    javascript_tag <<-JS
      observe_field({
        'kind': 'article',
        'field': jQuery('\#article_body'),
        'fieldName': 'body',
        'include': ['title'],
        'interval': 30,
        'url': '#{articles_url}.js',
        'before': function() { jQuery('\#spinner').show(); },
        'success': function(html) { jQuery('\#preview').html(html); },
        'error': function(html) { alert('an error occurred updating the preview'); },
        'complete': function() { jQuery('\#spinner').hide(); },
      });
    JS
  end
end
