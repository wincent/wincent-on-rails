class IssueObserver < ActiveRecord::Observer
  def before_save issue
    annotate issue unless issue.new_record?
  end

  def after_create issue
    send_new_issue_alert issue unless issue.user && issue.user.superuser?
  end

private

  def annotate issue
    annotations = []
    issue.changes.each do |change|
      field, from, to = change[0], change[1][0], change[1][1]
      annotations << case field
      when 'kind'
        format_annotation 'Kind', Issue.string_for_kind(from), issue.kind_string
      when 'status'
        format_annotation 'Status', Issue.string_for_status(from), issue.status_string
      when 'product_id'
        if from and to
          products  = Product.find from, to
          from      = products.find { |p| p.id == from }.name
          to        = products.find { |p| p.id == to }.name
        elsif from
          from, to  = Product.find(from).name, 'none'
        elsif to
          from, to  = 'none', Product.find(to).name
        end
        format_annotation('Product', from, to)
      when 'summary', 'public'
        format_annotation field.capitalize, from, to
      else # 'awaiting_moderation' ,'description'
        # no annotation
      end
    end

    if issue.pending_tags?
      from  = issue.tag_names.join(' ')
      to    = issue.pending_tags
      annotations << format_annotation('Tags', from, to) if from != to
    end

    annotations.compact!
    return if annotations.empty?
    comment = issue.comments.new :body => annotations.join("\n")
    user = Thread.current[:current_user]
    comment.user_id = user.id if user
    comment.awaiting_moderation = !(user && user.superuser?)
    comment.save
  end

  # Formats an annotation for a single field using appropriate wikitext markup.
  def format_annotation field, from, to
    "'''#{field}''' changed:\n" \
    "\n"                        \
    "* '''From:''' #{from}\n"   \
    "* '''To:''' #{to}"
  end

  def send_new_issue_alert issue
    IssueMailer.new_issue_alert(issue).deliver
  rescue Exception => e
    Rails.logger.error \
      "IssueObserver#send_new_issue_alert for issue #{issue.inspect} " \
      "failed due to exception #{e.class}: #{e.message}"
  end
end # class IssueObserver
