class HeartbeatController < ApplicationController
  # we don't want Monit filling up the logs with noise
  # (4 requests, 1 for each mongrel, every 30 seconds)
  self.logger = nil

  # lightweight request that tests the full stack
  # (routing, controller, database/model, views, Haml)
  def ping
    @tag = Tag.find(:first) || Tag.new
  end
end
