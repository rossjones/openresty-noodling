# Noodling about

Nothing to see here, just playing with openresty.

## Building/Installing

On **OSX**:

```
./configure --with-luajit --with-cc-opt="-I/usr/local/include" \
    --with-ld-opt="-L/usr/local/lib" --with-http_iconv_module \
    --with-http_postgres_module -j2
make
sudo make install
```

Make sure the new nginx is on the path

```
export PATH=/usr/local/openresty/nginx/sbin:$PATH
```

pull this code

```
git clone git@github.com:rossjones/openresty-noodling.git
cd openresty-noodling
```

openresty should be started with

```
nginx -p `pwd`/ -c conf/nginx.conf
```

but seeing as ```nginx -s reload``` doesn't work for me, use the nasty script in ```./restart```