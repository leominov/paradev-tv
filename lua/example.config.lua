redis = require "resty.redis"
red = redis:new()

redis_host = "127.0.0.1"
redis_port = 6379
redis_ttl = 2592000

playlist_url = "http://weburg.tv/playlist"
playlist_ct = "application/xspf+xml"

channel_prefix = "udp://@239.255."
channel_url = "http://localhost/channel?token=%s~"
redirect_url = "http://localhost:9418/udp/239.255."

allow_new_users = true
secret_key = "secret"
