require "config"

local ok, err = red:connect(redis_host, redis_port)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if ngx.var.arg_token:find("~") == nil then
    ngx.log(ngx.ERR, "Bad request")
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

divider = ngx.var.arg_token:find("~")
token = ngx.var.arg_token:sub(0, divider - 1)
ip = string.gsub(ngx.var.arg_token:sub(divider + 1), ":1234", "")

local user, err = red:get("t:" .. token)
if not user then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if user == ngx.null then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.log(ngx.ERR, "Unauthorized")
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

red:expire("t:" .. token, redis_ttl)

red:incr("c:" .. user .. ":" .. ip)
red.incr("c:" .. user)
red:incr("c:" .. ip)
red:incr("c:all")

return ngx.redirect(redirect_url .. ip)
