### Run OpenResty Container

```
podman run -d --name=openresty \
    -h openresty  \
    -p 8080:80    \
    -v ~/openresty-gateway/conf/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf:Z  \
    -v ~/openresty-gateway/lua:/usr/local/openresty/nginx/lua:Z  \
    registry.docker.ir/openresty/openresty
```
