FROM php:7-fpm-alpine

# install extensions
# intl, zip, soap
RUN apk add --update --no-cache git postgresql-dev autoconf g++ \
                                imagemagick-dev libtool make pcre-dev \
                                freetype-dev libjpeg-turbo-dev libpng-dev \
                                libmcrypt-dev \
    && pecl install imagick mcrypt-1.0.1\
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-install zip \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install json \
    && docker-php-ext-install session \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install exif \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd \
    && apk del autoconf g++ libtool make pcre-dev

RUN sed -i -e 's/listen.*/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.conf \
    && sed -i -e 's/output_buffering\s*=\s*4096/output_buffering = Off/g' /usr/local/etc/php-fpm.conf \
    && sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/etc/php-fpm.conf \
    && sed -i -e 's/upload_max_filesize\s*=\s*2M/upload_max_filesize = 1G/g' /usr/local/etc/php-fpm.conf \
    && sed -i -e 's/post_max_size\s*=\s*8M/post_max_size = 1G/g' /usr/local/etc/php-fpm.conf \
    && sed -i -e 's:;\s*session.save_path\s*=\s*\"N;/path\":session.save_path = /tmp:g' /usr/local/etc/php-fpm.conf \
    && echo 'expose_php=0' > /usr/local/etc/php/php.ini

WORKDIR /var/www

RUN git clone https://github.com/electerious/Lychee.git lychee \
    && chown -R www-data:www-data lychee /tmp  \
    && chmod -R 750 lychee/uploads lychee/data

VOLUME /var/www/lychee/uploads
VOLUME /var/www/lychee/data
