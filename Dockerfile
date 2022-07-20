FROM debian:stable-slim
LABEL maintainer=infraworks
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /tmp

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget build-essential libpcre2-dev libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN wget http://nginx.org/download/nginx-1.23.1.tar.gz \
    && tar xzf nginx-1.23.1.tar.gz

WORKDIR /tmp/nginx-1.23.1

RUN ./configure --with-cc-opt='-g -O2 -ffile-prefix-map=/build/nginx-QeqwpL/nginx-1.18.0=. -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -fPIC' \
    --prefix=/var/www/html \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/run/nginx.pid \
    --modules-path=/usr/lib/nginx/modules \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --with-compat --with-debug --with-pcre-jit \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_auth_request_module \
    --with-http_v2_module \
    --with-http_dav_module --with-http_slice_module \
    --with-threads --with-http_addition_module \
    --with-http_gunzip_module --with-http_gzip_static_module \
    --with-http_sub_module \
    && make \
    && make install \
    && rm -rf /tmp/* \
    && mkdir  --parents  /var/lib/nginx/body \
    && mkdir  --parents  /var/lib/nginx/fastcgi \
    && mkdir  --parents  /var/lib/nginx/proxy \
    && mkdir  --parents  /var/lib/nginx/uwsgi \
    && mkdir  --parents  /var/lib/nginx/scgi \
    && chown  --recursive  www-data:www-data  /var/lib/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stdout /var/log/nginx/error.log

EXPOSE 80/tcp

CMD ["/usr/sbin/nginx","-g","daemon off;"]

