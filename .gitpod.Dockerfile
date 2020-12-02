FROM php:7.4-fpm-alpine
LABEL maintainer="chenghao@ip-sky.cn"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update
RUN apk add --no-cache libc6-compat git openssh-client \
    libzip-dev libjpeg-turbo-dev libpng-dev freetype-dev incron
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
    linux-headers tzdata libstdc++
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd \
    zip pdo_mysql opcache mysqli pcntl bcmath \
    && docker-php-ext-configure pcntl --enable-pcntl
RUN TZ=Asia/Shanghai \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apk del .phpize-deps \
    && chmod 0777 /run \
    && printf "[PHP]\ndate.timezone = \"${TZ}\"\nexpose_php = Off\n" > /usr/local/etc/php/conf.d/tzone.ini \
    # set recommended PHP.ini settings
    # see https://secure.php.net/manual/en/opcache.installation.php
    && { \
       		echo 'opcache.memory_consumption=128'; \
       		echo 'opcache.interned_strings_buffer=8'; \
       		echo 'opcache.max_accelerated_files=4000'; \
       		echo 'opcache.revalidate_freq=2'; \
       		echo 'opcache.fast_shutdown=1'; \
       	} > /usr/local/etc/php/conf.d/opcache-recommended.ini \
    && { \
       # https://www.php.net/manual/en/errorfunc.constants.php
       # https://github.com/docker-library/wordpress/issues/420#issuecomment-517839670
       		echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
       		echo 'display_errors = Off'; \
       		echo 'display_startup_errors = Off'; \
       		echo 'log_errors = On'; \
       		echo 'error_log = /dev/stderr'; \
       		echo 'log_errors_max_len = 1024'; \
       		echo 'ignore_repeated_errors = On'; \
       		echo 'ignore_repeated_source = Off'; \
       		echo 'html_errors = Off'; \
       	} > /usr/local/etc/php/conf.d/error-logging.ini
