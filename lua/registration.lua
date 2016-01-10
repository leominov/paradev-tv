require "config"

local resty_random = require "resty.random"
local resty_md5 = require "resty.md5"
local str = require "resty.string"
local json = require("cjson")

ngx.header.content_type = "application/json"

if not allow_new_users then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say(json.encode({result=false, error_code="allow_new_users"}))
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

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
local user_key = "u:" .. login

local res, err = red:get("u:" .. ngx.var.arg_login)
if not res then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({result=false, error_code="redis_get"}))
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if type(res) == "string" then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say(json.encode({result=false, error_code="inlogin_error"}))
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local user_data = login .. secret_key .. password
local md5 = resty_md5:new()
md5:update(user_data)
local digest = md5:final()

local md5 = resty_md5:new()
md5:update(user_data .. str.to_hex(resty_random.bytes(16)))
local digest_token = md5:final()

local user = {
    login = login,
    password = str.to_hex(digest),
    token = str.to_hex(digest_token)
}

local res, err = red:set(user_key, json.encode(user))
if not res then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(json.encode({result=false, error_code="redis_set"}))
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

ngx.say(json.encode({result=true, token=user.token}))

red:set("t:" .. user.token, login)
red:expire("t:" .. user.token, redis_ttl)
