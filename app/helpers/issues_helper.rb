module IssuesHelper
  def issue_tooltip issue
    "#{issue.kind_string} \##{issue.id}: #{issue.summary}"
  end

  def link_to_prev_issue issue
    if issue
      link_to '&laquo; previous'.html_safe, issue_path(issue),
        :title => issue_tooltip(issue)
    end
  end

  def link_to_next_issue issue
    if issue
      link_to 'next &raquo;'.html_safe, issue_path(issue),
        :title => issue_tooltip(issue)
    end
  end

  def kind_options_for_select
    options_for_select underscores_to_spaces(Issue::KIND).sort
  end

  def status_options_for_select
    options_for_select underscores_to_spaces(Issue::STATUS).sort
  end
end
