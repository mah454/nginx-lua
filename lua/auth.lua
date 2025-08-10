local jwt = require "resty.jwt"
local cjson = require "cjson"

-- === Config ===
local secret = "my_shared_secret"  -- Replace with your real secret or load from env
local alg = "HS256"                -- or "RS256" if using public/private keys

-- === Extract Authorization header ===
local auth_header = ngx.var.http_Authorization
if not auth_header then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(cjson.encode({ error = "Missing Authorization header" }))
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local token = auth_header:match("Bearer%s+(.+)")
if not token then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(cjson.encode({ error = "Invalid Authorization format" }))
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- === Verify JWT ===
local jwt_obj = jwt:verify(secret, token)
if not jwt_obj.verified then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say(cjson.encode({ error = "Token verification failed", reason = jwt_obj.reason }))
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- === Set identity headers for upstream ===
ngx.req.set_header("X-User", jwt_obj.payload.sub or "")
ngx.req.set_header("X-Roles", table.concat(jwt_obj.payload.roles or {}, ","))
