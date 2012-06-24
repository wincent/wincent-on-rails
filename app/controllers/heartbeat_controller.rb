class HeartbeatController < ApplicationController
  # we don't want Monit filling up the logs with noise;
  # not sure why, but this method cannot be protected or private
  # (due to routing, however, this action can never be hit anyway)
  def logger
    nil
  end

  # lightweight request that tests the full stack
  # (routing, controller, database/model, views, Haml)
  def ping
    @tag = Tag.first || Tag.new
  end
end
