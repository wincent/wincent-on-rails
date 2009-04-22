module PostsHelper
  def excerpt_html options = {}
    level = options[:base_heading_level] || 1
    @post.excerpt.w :base_heading_level => level
  end

  def body_html
    @post.body ? (@post.body.w :base_heading_level => 1) : ''
  end

  def title_excerpt_and_body_html
    text = []
    text << (@post.title.blank? ? '' : "= #{@post.title} =")
    text << (@post.excerpt || '')
    text << (@post.body || '')
    text.join("\n\n").w :base_heading_level => 2
  end

  def link_to_update_preview
    onclick = inline_js do
      <<-JS
        $('\#spinner').show();
        $.ajax({
          'url': '#{posts_url}.js',
          'type': 'post',
          'dataType': 'html',
          'data': 'title=' + encodeURIComponent($('\#post_title').val()) +
            '&excerpt=' + encodeURIComponent($('\#post_excerpt').val()) +
            '&body=' + encodeURIComponent($('\#post_body').val()),
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
        'kind': 'post',
        'field': $('\#post_title'),
        'fieldName': 'title',
        'include': ['excerpt', 'body'],
        'url': '#{posts_url}.js',
        'error': function(req) {
          insertAJAXFlash('error', req.responseText);
        },
        'complete': function() { $('\#spinner').hide(); },
      });
    JS
  end

  def observe_excerpt
    javascript_tag <<-JS
      observe_field({
        'kind': 'post',
        'field': $('\#post_excerpt'),
        'fieldName': 'excerpt',
        'include': ['title', 'body'],
        'url': '#{posts_url}.js',
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
        'kind': 'post',
        'field': $('\#post_body'),
        'fieldName': 'body',
        'include': ['title', 'excerpt'],
        'url': '#{posts_url}.js',
        'error': function(req) {
          insertAJAXFlash('error', req.responseText);
        },
        'complete': function() { $('\#spinner').hide(); },
      });
    JS
  end

  def comment_count number
    pluralizing_count number, 'comment'
  end

  def comments_link post
    # NOTE: the problem with this method was that it was causing an "n +  1" SELECT problem in the index action
    # basically, calling "ham_count" unavoidably provokes a database query for each post;
    # the counter_cache is useless (and unused) in this case
    #
    # Previously, the code looked like this:
    #
    #   if post.accepts_comments? || post.comments.ham_count > 0
    #     link_to comment_count(post.comments.ham_count) ...
    #
    # For now we avoid the unwanted SELECTS by providing a ham + spam count which uses the counter cache
    if post.accepts_comments? || post.comments_count > 0
       link_to comment_count(post.comments_count),
        { :controller => 'posts', :action => 'show', :id => @post.to_param, :anchor => 'comments'},
        :class => 'comments_link'
    else
      ''
    end
  end
end
