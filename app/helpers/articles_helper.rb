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
        $('\#spinner').show();
        $.ajax({
          'url': '#{articles_url}.js',
          'type': 'post',
          'dataType': 'html',
          'data': 'title=' + encodeURIComponent($('\#article_title').val()) +
            '&body=' + encodeURIComponent($('\#article_body').val()),
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

  def observe_title
    javascript_tag <<-JS
      observe_field({
        'kind': 'article',
        'field': $('\#article_title'),
        'fieldName': 'title',
        'include': ['body'],
        'interval': 30,
        'url': '#{articles_url}.js',
        'before': function() { $('\#spinner').show(); },
        'success': function(html) {
          $('\#preview').html(html);
          clearAJAXFlash();
        },
        'error': function(req) {
           insertAJAXFlash('error', req.responseText);
        },
        'complete': function() { $('\#spinner').hide(); },
      });
    JS
  end

  def observe_body
    javascript_tag <<-JS
      observe_field({
        'kind': 'article',
        'field': $('\#article_body'),
        'fieldName': 'body',
        'include': ['title'],
        'interval': 30,
        'url': '#{articles_url}.js',
        'before': function() { $('\#spinner').show(); },
        'success': function(html) {
          $('\#preview').html(html);
          clearAJAXFlash();
        },
        'error': function(req) {
          insertAJAXFlash('error', req.responseText);
        },
        'complete': function() { $('\#spinner').hide(); },
      });
    JS
  end
end
