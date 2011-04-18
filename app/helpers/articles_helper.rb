module ArticlesHelper
  def redirected_from
    if @redirected_from
      content_tag :p do
        edit_link = if admin?
          ' [' + link_to("edit", edit_article_path(@redirected_from)) + ']'
        else
          ''
        end

        raw "(Redirected from #{h @redirected_from.title}#{edit_link})"
      end
    end
  end
end
