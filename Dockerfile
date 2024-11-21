FROM php:8.2-fpm

ARG user=claudio
ARG uid=1000

RUN apt-get update && apt-get install -y \
    wkhtmltopdf \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    vim \
    sudo \
    nano \
    zip \
    unzip \
    gnupg2

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets xml zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user \
    && mkdir -p /home/$user/.composer \
    && chown -R $user:$user /home/$user

RUN pecl install -o -f redis \
    && docker-php-ext-enable redis

WORKDIR /var/www

COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

RUN echo "$user:password" | chpasswd

RUN usermod -aG sudo $user

USER $user
