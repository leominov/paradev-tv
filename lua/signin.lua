require "config"

local resty_random = require "resty.random"
local resty_md5 = require "resty.md5"
local str = require "resty.string"
local json = require("cjson")

ngx.header.content_type = "application/json"

local ok, err = red:connect(redis_host, redis_port)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({result=false, error_code="redis_connect"}))
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if not ngx.var.arg_login or not ngx.var.arg_password then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say(json.encode({result=false, error_code="login_password"}))
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local login = ngx.var.arg_login
local password = ngx.var.arg_password

local res, err = red:get("u:" .. login)
if not res then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({result=false, error_code="redis_get"}))
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if type(res) ~= "string" then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say(json.encode({result=false, error_code="login_error"}))
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local user_data = login .. secret_key .. password
local md5 = resty_md5:new()
md5:update(user_data)
local digest = md5:final()

user = json.decode(res)
if user.password ~= str.to_hex(digest) then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(json.encode({result=false, error_code="auth_error"}))
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

red:del("t:" .. user.token)

local md5 = resty_md5:new()
md5:update(user_data .. str.to_hex(resty_random.bytes(16)))
local digest_token = md5:final()
user.token = str.to_hex(digest_token)

red:set("u:" .. login, json.encode(user))
red:set("t:" .. user.token, login)
red:expire("t:" .. user.token, redis_ttl)

ngx.say(json.encode({result=true, token=user.token}))
