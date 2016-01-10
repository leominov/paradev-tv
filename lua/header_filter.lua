local m = ngx.req.get_method()

if m == "GET" or m == "POST" then
    ngx.header["Access-Control-Allow-Origin"] = ngx.var.http_origin
    ngx.header["Access-Control-Allow-Credentials"] = "true"
elseif m == "OPTIONS" then
    ngx.header["Access-Control-Allow-Origin"] = ngx.var.http_origin
    ngx.header["Access-Control-Allow-Credentials"] = "true"
    ngx.header["Access-Control-Max-Age"] = "1728000"
    ngx.header["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    ngx.header["Access-Control-Allow-Headers"] = "Authorization,X-Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since"
    ngx.header["Content-Length"] = "0"
    ngx.header["Content-Type"] = "text/plain charset=UTF-8"
end
