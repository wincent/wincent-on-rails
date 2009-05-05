class AttachmentsController < ApplicationController
  before_filter :require_admin

  # Admin only.
  def new
  end
end
