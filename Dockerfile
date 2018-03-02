FROM alpine:3.7

# trust this project public key to trust the packages.
ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

## you may join the multiple run lines here to make it a single layer

# make sure you can use HTTPS
RUN apk --update add ca-certificates

# add the repository, make sure you replace the correct versions if you want.
RUN echo "@php https://php.codecasts.rocks/v3.7/php-7.1" >> /etc/apk/repositories

# install php and some extensions
# notice the @php is required to avoid getting default php packages from alpine instead.
RUN apk add --update php7@php
RUN apk add --update php7-mbstring@php \
    php7-ctype@php \
    php7-curl@php \
    php7-json@php \
    php7-xml@php \
    php7-mcrypt@php \
    php7-zip@php \
    php7-memcached@php \
    php7-phar@php \
    php7-gd@php \
    php7-dom@php \
    php7-xdebug@php \
    php7-bcmath@php \
    php7-intl@php \
    php7-pdo_mysql@php

# Create symlink
RUN ln -s /usr/bin/php7 /usr/bin/php

# remove load xdebug extension (only load on phpunit command)
RUN sed -i 's/^/;/g' /etc/php7/conf.d/00_xdebug.ini

# Install tools
RUN apk add --no-cache curl git bash

# Install composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install phpcs
RUN composer global require 'squizlabs/php_codesniffer=*' \
    && cd ~/.composer/vendor/squizlabs/php_codesniffer/src/Standards/ \
    && git clone https://github.com/wataridori/framgia-php-codesniffer.git Framgia

# Create symlink
RUN ln -s /root/.composer/vendor/bin/phpcs /usr/bin/phpcs

# Install nodejs, npm, yarn...
RUN apk add --no-cache nodejs-npm
RUN npm i -g eslint babel-eslint eslint-plugin-react yarn

RUN apk add --no-cache --virtual .gyp \
    python \
    make \
    g++

# Clean up
RUN apk del curl git

WORKDIR /var/www/laravel
