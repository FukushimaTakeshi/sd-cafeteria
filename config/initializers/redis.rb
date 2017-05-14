require 'redis'

if Rails.env.production?
  if ENV["REDISCLOUD_URL"]
    Redis.current = Redis.new(:url => ENV["REDISCLOUD_URL"])
  end
else
  Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379)
end
