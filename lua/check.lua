require "config"

local json = require("cjson")

ngx.header.content_type = "application/json"

if allow_new_users then
    ngx.say(json.encode({result=true}))
else
    ngx.say(json.encode({result=false}))
end
