require "config"

local json = require("cjson")

ngx.header.content_type = "application/json"

local ok, err = red:connect(redis_host, redis_port)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({result=false, error_code="redis_connect"}))
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local p, err = red:get("p:all")
if not p then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({result=false, error_code="redis_get"}))
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local c, err = red:get("c:all")
if not c then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({result=false, error_code="redis_get"}))
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

stat = {
    p = p,
    c = c
}

ngx.say(json.encode({result=true, stat=stat}))
