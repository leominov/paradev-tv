require "config"

local json = require("cjson")

ngx.header.content_type = "application/json"

local ok, err = red:connect(redis_host, redis_port)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({
        code = ngx.status,
        message = "redis_connect"
    }))

    return ngx.exit(ngx.status)
end

local headers = ngx.req.get_headers()
local auth_data = headers["X-Authorization"]

if not auth_data or auth_data:find("~") == nil then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say(json.encode({
        code = ngx.status,
        message = "auth_data"
    }))

    return ngx.exit(ngx.status)
end

divider = auth_data:find("~")
login = auth_data:sub(0, divider - 1)
token = auth_data:sub(divider + 1)

local user_data = red:get("u:" .. login)
if not user_data then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({
        code = ngx.status,
        message = "redis_get"
    }))

    return ngx.exit(ngx.status)
end

if type(user_data) ~= "string" then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say(json.encode({
        code = ngx.status,
        message = "login_error"
    }))

    return ngx.exit(ngx.status)
end

user = json.decode(user_data)
user.password = nil

if user.token ~= token then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(json.encode({
        code = ngx.status,
        message = "auth_error"
    }))

    return ngx.exit(ngx.status)
end

ttl = red:ttl("t:" .. token)

ngx.say(json.encode({
    ttl = ttl,
    user = user
}))
