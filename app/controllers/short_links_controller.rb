class ShortLinksController < ApplicationController
  before_filter :find_link

  def show
    Link.increment_counter :click_count, @link.id
    redirect_to @link.redirection_url, status: 302
  end

private

  def find_link
    @link = Link.find(ShortLink.decode(params[:id]))
  end

  def record_not_found
    redirect_to APP_CONFIG[:protocol] + '://' + APP_CONFIG[:host]
  end
end
