if not ngx.var.arg_token then
    ngx.log(ngx.ERR, "Unauthorized")
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end
