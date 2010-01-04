require File.dirname(__FILE__) + '/culerity/remote_object_proxy'
require File.dirname(__FILE__) + '/culerity/remote_browser_proxy'

Symbol.class_eval do
  def to_proc
    Proc.new{|object| object.send(self)}
  end
end unless :symbol.respond_to?(:to_proc)

module Culerity

  module ServerCommands
    def exit_server
      self << '["_exit_"]'
      Process.kill(6, self.pid.to_i)
    end

    def close_browsers
      self.puts '["_close_browsers_"]'
    end
  end

  def self.run_server
    IO.popen("jruby #{__FILE__}", 'r+').extend(ServerCommands)
  end
  
  def self.run_rails(options = {})
    if defined?(Rails) && !File.exists?("tmp/culerity_rails_server.pid")
      puts "WARNING: Speed up execution by running 'rake culerity:rails:start'"
      port        = options[:port] || 3001
      environment = options[:environment] || 'culerity_development'
      rails_server = IO.popen("script/server -e #{environment} -p #{port}", 'r+')
      sleep 5
      rails_server
    end
  end
end

if __FILE__ == $0
  require File.dirname(__FILE__) + '/culerity/celerity_server'
  Culerity::CelerityServer.new STDIN, STDOUT
end

