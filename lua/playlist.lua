require "config"

local ok, err = red:connect(redis_host, redis_port)
if not ok then
    ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local user, err = red:get("t:" .. ngx.var.arg_token)
if not user then
    ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

ngx.log(ngx.ERR, "t:" .. ngx.var.arg_token)
ngx.log(ngx.ERR, user)

if user == ngx.null then
    ngx.log(ngx.ERR, "Unauthorized")
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

red:expire("t:" .. ngx.var.arg_token, redis_ttl)

local http = require "resty.http"
local httpc = http:new()
local res, err = httpc:request_uri(playlist_url)

if not res then
    red:incr("p-e:" .. user)
    red:incr("p-e:all")
    ngx.log(ngx.ERR, "Failed to request: ", err)

    return ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end

red:incr("p:" .. user)
red:incr("p:all")

ngx.header["Content-type"] = playlist_ct
ngx.status = res.status

local body = string.gsub(res.body, channel_prefix, string.format(channel_url, ngx.var.arg_token))

ngx.say(body)
