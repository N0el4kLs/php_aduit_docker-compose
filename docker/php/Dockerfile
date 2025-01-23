FROM php:7.3-fpm
#FROM php:8.2-fpm

RUN sed -i s/deb.debian.org/mirrors.aliyun.com/g /etc/apt/sources.list \
	&& sed -i s/security.debian.org/mirrors.ustc.edu.cn/g /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libjpeg-dev \
        pkg-config \
        libmcrypt-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libzip-dev \
        zip \
        && docker-php-ext-install zip pdo pdo_mysql mysqli

RUN docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-freetype-dir=/usr/include/freetype2/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install opcache && \
    docker-php-ext-enable opcache

RUN pecl install xdebug-3.0.3 \
    && docker-php-ext-enable xdebug

RUN apt-get clean && rm -rf /var/lib/apt/lists/*