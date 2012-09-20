class MiscController < ApplicationController
  before_filter :require_admin, only: :style_guide

  def style_guide
    render
  end

  def wikitext_cheatsheet
    render layout: 'empty'
  end
end
