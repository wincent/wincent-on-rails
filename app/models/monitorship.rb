class Monitorship < ActiveRecord::Base
  belongs_to      :user
  belongs_to      :monitorable, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :monitorable
end
