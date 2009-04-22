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
end
