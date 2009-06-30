# The Message class models an incoming or outgoing email message.
# In general, a message will have an associated "related" object.
#
# For example, an incoming mail to "support@wincent.com" will
# either be matched up with an existing Issue record, or a new
# Issue will be created.
#
# Outgoing mail such as email address confirmations will be
# associated with the related Confirmation record.
#
# The primary purposes of this model are to capture information for
# debugging, and track Message-ID headers so that when a user
# replies to outgoing messages the reply can be assigned to the
# appropriate existing Issue (if one exists).
#
# Table fields:
#
#   integer     :related_id
#   string      :related_type
#   string      :message_id_header
#   string      :to_header
#   string      :from_header
#   string      :subject_header
#   string      :in_reply_to_header
#   text        :body
#   boolean     :incoming, :default => true, :null => false
#   timestamps
#
class Message < ActiveRecord::Base
  belongs_to :related, :polymorphic => true

  # internally generated from "safe" inputs, so basically everything is
  # accessible
  attr_accessible :related, :message_id_header, :to_header, :from_header,
    :subject_header, :in_reply_to_header, :body, :incoming
end
