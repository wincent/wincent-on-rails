class Monitorship < ActiveRecord::Base
  belongs_to      :user
  belongs_to      :monitorable, :polymorphic => true
  attr_accessor   :nothing
  attr_accessible :nothing
end
